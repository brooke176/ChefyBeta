import UIKit
import Messages
import SwiftUI

class MessagesViewController: MSMessagesAppViewController {
    var gameState: GameState = GameState()
    private var conversationManager: ConversationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)

        if let message = conversation.selectedMessage, let url = message.url {
            decodeGameState(from: url) { [weak self] decodedState in
                guard let self = self else { return }
                if let decodedState = decodedState {
                    self.gameState = decodedState
                    self.showSteakGameView(with: self.gameState)
                } else {
                    conversationManager = ConversationManager(conversation: conversation)
                    let contentView = ContentView(conversation: conversation, conversationManager: conversationManager!)
                    let hostingController = UIHostingController(rootView: contentView)
                    addChild(hostingController)
                    view.addSubview(hostingController.view)
                    hostingController.didMove(toParent: self)
                    hostingController.view.frame = view.bounds
                }
            }
        } else {
            conversationManager = ConversationManager(conversation: conversation)
            let contentView = ContentView(conversation: conversation, conversationManager: conversationManager!)
            let hostingController = UIHostingController(rootView: contentView)
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            hostingController.view.frame = view.bounds
        }
    }

    private func decodeGameState(from url: URL, completion: @escaping (GameState?) -> Void) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            completion(nil)
            return
        }

        var gameState = GameState()

        for item in queryItems {
            switch item.name {
            case "player1Score":
                gameState.player1Score = Int(item.value ?? "0") ?? 0
            case "player2Score":
                gameState.player2Score = Int(item.value ?? "0") ?? 0
            case "player1Played":
                gameState.player1Played = (item.value == "true")
            case "player2Played":
                gameState.player2Played = (item.value == "true")
            case "currentPlayer":
                gameState.currentPlayer = item.value
            default:
                break
            }
        }

        completion(gameState)
    }

    private func setupChildViewController(_ childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)

        childController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            childController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

        private func showSteakGameView(with gameState: GameState) {
            let steakGameView = SteakGameView(gameState: .constant(gameState), messagesViewController: self) // Adjust initialization as needed
            let hostingController = UIHostingController(rootView: steakGameView)
            setupChildViewController(hostingController)
        }
    
//    private func showSteakGameView(with gameState: GameState) {
//        let viewModel = GameViewModel(gameState: gameState)
//        let steakGameView = SeasonSteakStep(viewModel: viewModel, messagesViewController: self)
//        let hostingController = UIHostingController(rootView: steakGameView)
//        setupChildViewController(hostingController)
//    }

    func startOrResetGame() {
        gameState = GameState(currentPlayer: "player1")
        updateAndSendGameState()
    }
    
    func updateAndSendGameState() {
        guard let conversation = activeConversation else { return }
        
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = "Your turn!"
        message.layout = layout
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "player1Score", value: String(gameState.player1Score)),
            URLQueryItem(name: "player2Score", value: String(gameState.player2Score)),
            URLQueryItem(name: "player1Played", value: String(gameState.player1Played)),
            URLQueryItem(name: "player2Played", value: String(gameState.player2Played))
        ]
        
        message.url = components.url
        
        conversation.insert(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func composeMessage(with gameState: GameState, session: MSSession? = nil) -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = "Let's play Steak Game!!"
        message.layout = layout
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "player1Score", value: "\(gameState.player1Score)"),
            URLQueryItem(name: "player2Score", value: "\(gameState.player2Score)"),
            URLQueryItem(name: "player1Played", value: "\(gameState.player1Played)"),
            URLQueryItem(name: "player2Played", value: "\(gameState.player2Played)"),
            URLQueryItem(name: "currentPlayer", value: gameState.currentPlayer)
        ]
        
        message.url = components.url
        message.layout = layout
                
        return message
    }

    // MARK: - Conversation Handling

    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.

        // Use this method to prepare for the change in presentation style.
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.

        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
}
