import UIKit
import Messages
import SwiftUI

class MessagesViewController: MSMessagesAppViewController {
    var gameState: GameState = GameState()
    private var conversationManager: ConversationManager?
    
//    override func willBecomeActive(with conversation: MSConversation) {
//        super.willBecomeActive(with: conversation)
//        let conversationManager = ConversationManager(conversation: conversation)
//        self.conversationManager = conversationManager
//
//        if gameState.currentPlayer == nil {
//            gameState.currentPlayer = "player1"
//            gameState.player1Id = conversation.localParticipantIdentifier.uuidString
//        }
//
//        if let messageURL = conversation.selectedMessage?.url {
//            conversationManager.decodeGameState(from: messageURL) { [weak self] decodedGameState in
//                guard let self = self else { return }
//                if let decodedGameState = decodedGameState {
//                    self.gameState = decodedGameState
//                    if conversation.localParticipantIdentifier.uuidString == self.gameState.player1Id {
//                        self.gameState.currentPlayer = "player1"
//                    } else {
//                        self.gameState.currentPlayer = "player2"
//                    }
//
//                    if self.gameState.player1Played && self.gameState.player2Played {
//                        self.presentOutcomeView(with: self.gameState)
//                    } else {
//                        self.handleGameSelection(using: conversationManager, conversation: conversation)
//                    }
//                } else {
//                    self.presentContentView(conversation: conversation)
//                }
//            }
//        } else {
//            presentContentView(conversation: conversation)
//        }
//    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        let conversationManager = ConversationManager(conversation: conversation)
        self.conversationManager = conversationManager

        if gameState.currentPlayer == nil {
            gameState.currentPlayer = "player1"
            gameState.player1Id = conversation.localParticipantIdentifier.uuidString
        }

        if let messageURL = conversation.selectedMessage?.url {
            conversationManager.decodeGameState(from: messageURL) { [weak self] decodedGameState in
                guard let self = self else { return }

                if let decodedGameState = decodedGameState {
                    self.gameState = decodedGameState

                    if conversation.localParticipantIdentifier.uuidString == self.gameState.player1Id {
                        self.gameState.currentPlayer = "player1"
                    } else {
                        self.gameState.currentPlayer = "player2"
                    }

                    if self.gameState.player1Played && self.gameState.player2Played {
                        self.presentOutcomeView(with: self.gameState)
                    } else {
                        self.handleGameSelection(using: conversationManager, conversation: conversation)
                    }
                } else {
                    self.presentContentView(conversation: conversation)
                }
            }
        } else {
            presentContentView(conversation: conversation)
        }
    }
    
//    override func willBecomeActive(with conversation: MSConversation) {
//        super.willBecomeActive(with: conversation)
//
//        let viewModel = PancakeGameViewModel(gameState: gameState, messagesViewController: self)
//        let SteakSeasoningViewView = CrackEggsView(viewModel: viewModel, messagesViewController: self)
//        presentPancakeGame(viewModel: viewModel)
//
//        let hostingController = UIHostingController(rootView: SteakSeasoningViewView)
//
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }

    func updateAndSendGameState(completion: @escaping () -> Void) {
        guard let conversation = activeConversation else {
            completion()
            return
        }
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = "Your turn!"
        message.layout = layout
        print("gameStategameState", gameState)

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "gameType", value: gameState.gameType ?? ""),
            URLQueryItem(name: "player1Score", value: String(gameState.player1Score)),
            URLQueryItem(name: "player2Score", value: String(gameState.player2Score)),
            URLQueryItem(name: "player1Played", value: String(gameState.player1Played)),
            URLQueryItem(name: "player2Played", value: String(gameState.player2Played)),
            URLQueryItem(name: "currentPlayer", value: gameState.currentPlayer)
        ]

        message.url = components.url
        self.presentOutcomeView(with: self.gameState)

        conversation.insert(message) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }

    private func handleGameSelection(using conversationManager: ConversationManager, conversation: MSConversation) {
        if let selectedGameType = conversationManager.decodeSelectedGameType(from: conversation) {
            switch selectedGameType {
            case .BeefWelly:
                let viewModel = SteakGameViewModel(gameState: gameState, messagesViewController: self)
                if gameState.player1Played && gameState.player2Played || !gameState.player1Played && gameState.currentPlayer == "player2" && gameState.player2Played || !gameState.player2Played && gameState.currentPlayer == "player1" && gameState.player1Played {
                    DispatchQueue.main.async {
                        viewModel.currentStage = .outcome
                    }
                }
                presentSteakGame(viewModel: viewModel)
                viewModel.onRequestCompactMode = { [weak self] in
                    self?.requestPresentationStyle(.compact)
                }
            case .pancakes:
                let viewModel = PancakeGameViewModel(gameState: gameState, messagesViewController: self)
                if gameState.player1Played && gameState.player2Played || !gameState.player1Played && gameState.currentPlayer == "player2" && gameState.player2Played || !gameState.player2Played && gameState.currentPlayer == "player1" && gameState.player1Played {
                    DispatchQueue.main.async {
                        viewModel.currentStage = .outcome
                    }
                }
                presentPancakeGame(viewModel: viewModel)
            }
        } else {
            presentContentView(conversation: conversation)
        }
    }

    private func presentContentView(conversation: MSConversation) {
        let contentView = ContentView(conversation: conversation, delegate: self)
        let hostingController = UIHostingController(rootView: contentView)
        setupChildViewController(hostingController)
    }

    private func presentOutcomeView(with gameState: GameState) {
        let viewModel = SteakGameViewModel(gameState: gameState, messagesViewController: self)
        let gameOutcomeView = GameOutcomeView(gameState: gameState, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: gameOutcomeView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
        requestPresentationStyle(.compact)
    }

    private func presentSteakGame(viewModel: SteakGameViewModel) {
        let rootView = ZStack {
            switch viewModel.currentStage {
            case .some(.outcome):
                GameOutcomeView(gameState: viewModel.gameState, viewModel: viewModel)
            default:
                SteakGameFlowView(viewModel: viewModel, messagesViewController: self)
            }
        }
        presentView(rootView)
    }

    private func presentPancakeGame(viewModel: PancakeGameViewModel) {
        let view = CrackEggsView(viewModel: viewModel, messagesViewController: self)
        presentView(view)
    }

    private func presentView<T: View>(_ view: T) {
        let hostingController = UIHostingController(rootView: view)
        setupChildViewController(hostingController)
    }

    private func setupChildViewController(_ viewController: UIViewController) {
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Conversation Handling

    override func didResignActive(with conversation: MSConversation) {
        // Release shared resources, save user data, invalidate timers, and store state information
        // to restore the extension to its current state in case it is terminated later.
        saveCurrentGameState()
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Handle sending the game state when the user taps the send button.
        if gameState.gameHasStarted {
            updateAndSendGameState {
                print("Game state sent successfully.")
            }
        }
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Clean up state related to the deleted message.
        print("Message sending canceled.")
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Prepare for the change in presentation style.
        print("Will transition to presentation style: \(presentationStyle)")
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Finalize any behaviors associated with the change in presentation style.
        print("Did transition to presentation style: \(presentationStyle)")
        handlePresentationStyleChange(presentationStyle)
    }

    private func saveCurrentGameState() {
        // Save the current game state for restoration later.
        print("Saving current game state.")
        // Implement the saving mechanism here.
    }

    private func handlePresentationStyleChange(_ presentationStyle: MSMessagesAppPresentationStyle) {
        switch presentationStyle {
        case .compact:
            print("Transitioned to compact style.")
            // Handle compact style specific changes if needed.
        case .expanded:
            print("Transitioned to expanded style.")
            // Handle expanded style specific changes if needed.
        case .transcript:
            print("Transitioned to transcript style.")
            // Handle transcript style specific changes if needed.
        @unknown default:
            fatalError("Unknown presentation style.")
        }
    }
}

extension MessagesViewController: GameLaunchDelegate {
    func launchGame(for item: ImageItem) {
        switch item.label.lowercased() {
        case "pancakes":
            let viewModel = PancakeGameViewModel(gameState: gameState, messagesViewController: self)
            presentPancakeGame(viewModel: viewModel)
        case "beef welly":
//            let viewModel = SteakGameViewModel(gameState: gameState, messagesViewController: self)
//            presentSteakGame(viewModel: viewModel)
            let viewModel = SteakGameViewModel(gameState: gameState, messagesViewController: self)
//            if gameState.player1Played && gameState.player2Played || !gameState.player1Played && gameState.currentPlayer == "player2" && gameState.player2Played || !gameState.player2Played && gameState.currentPlayer == "player1" && gameState.player1Played {
//                DispatchQueue.main.async {
//                    viewModel.currentStage = .outcome
//                }
//            }
            presentSteakGame(viewModel: viewModel)
//            viewModel.onRequestCompactMode = { [weak self] in
//                self?.requestPresentationStyle(.compact)
//            }
        default:
            break
        }
    }
}
