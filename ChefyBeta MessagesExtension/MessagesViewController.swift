import UIKit
import Messages
import SwiftUI

class MessagesViewController: MSMessagesAppViewController {
    
//    func sendGameState(score: Int, session: MSSession? = nil) {
//        guard let conversation = activeConversation else { return }
//        
//        let session = session ?? MSSession()
//        let message = MSMessage(session: session)
//        
//        let layout = MSMessageTemplateLayout()
//        layout.caption = "Steak Cooking Game"
//        layout.subcaption = "Score: \(score)"
//        message.layout = layout
//        
//        // Add URL components for the game state if needed
//        var components = URLComponents()
//        let scoreQueryItem = URLQueryItem(name: "score", value: "\(score)")
//        components.queryItems = [scoreQueryItem]
//        message.url = components.url
//        
//        // Insert the message into the conversation
//        conversation.insert(message) { error in
//            if let error = error {
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func parseGameState(from url: URL) -> GameState {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return GameState() }
        
        var gameState = GameState()
        for item in queryItems {
            switch item.name {
            case "player1Score":
                gameState.player1Score = Int(item.value ?? "0") ?? 0
            case "player2Score":
                gameState.player2Score = Int(item.value ?? "0") ?? 0
            case "gameStatus":
                gameState.gameStatus = item.value ?? "waitingForPlayer1"
            default:
                break
            }
        }
        return gameState
    }

    
    // Parse an incoming message to extract game state
    func parseMessage(_ message: MSMessage) -> Int? {
        guard let messageURL = message.url,
              let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else { return nil }
        
        for item in queryItems {
            if item.name == "score", let value = item.value, let score = Int(value) {
                return score
            }
        }
        
        return nil
    }
//this one works
//    override func didBecomeActive(with conversation: MSConversation) {
//        super.didBecomeActive(with: conversation)
//
//        // Set up and present the ContentView, passing the active conversation.
//        let contentView = ContentView(conversation: conversation)
//        let hostingController = UIHostingController(rootView: contentView)
//
//        // Add hostingController to the view hierarchy
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//
//        // Set constraints for hostingController's view
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)

        let conversationManager = ConversationManager(conversation: conversation)

        // Determine if there's an existing game state
        if let message = conversation.selectedMessage, let gameState = conversationManager.parseGameState(from: message) {
            let steakGameView = SteakGameView(conversationManager: conversationManager, gameState: gameState)
            presentSteakGameView(steakGameView)
        } else {
            // No game state, start a new game
            let contentView = ContentView(conversation: conversation)
            let hostingController = UIHostingController(rootView: contentView)
                  addChild(hostingController)
                  view.addSubview(hostingController.view)
                  hostingController.didMove(toParent: self)
          
                  // Set constraints for hostingController's view
                  hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                  NSLayoutConstraint.activate([
                      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                  ])
        }
    }

    private func presentSteakGameView(_ view: SteakGameView) {
        let hostingController = UIHostingController(rootView: view)

        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view.
    //    }

    // MARK: - Conversation Handling

    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.

        // Use this method to configure the extension and restore previously stored state.
    }

    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        var gameState = GameState()

        guard let messageURL = message.url,
              let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else { return }
        
        var opponentScore: Int?
        var turnTaken: Bool = false
        
        for item in queryItems {
            if item.name == "playerScore", let value = item.value, let score = Int(value) {
                opponentScore = score
            } else if item.name == "turnTaken", let value = item.value, let taken = Bool(value) {
                turnTaken = taken
            }
        }
        
        // Update your game state with the opponent's score and proceed to determine the winner
        if let opponentScore = opponentScore, turnTaken {
            gameState.player2Score = opponentScore
        }
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
