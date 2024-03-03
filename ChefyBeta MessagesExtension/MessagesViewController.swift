import UIKit
import Messages
import SwiftUI

protocol GameViewModelProtocol: AnyObject {
    func setupGameView(messagesViewController: MessagesViewController)
}

class MessagesViewController: MSMessagesAppViewController {
    var gameState: GameState = GameState()
    private var conversationManager: ConversationManager?

//    override func willBecomeActive(with conversation: MSConversation) {
//        super.willBecomeActive(with: conversation)
//
//        let conversationManager = ConversationManager(conversation: conversation)
//        self.conversationManager = conversationManager
//
//        if let messageURL = conversation.selectedMessage?.url {
//            conversationManager.decodeGameState(from: messageURL) { [weak self] decodedGameState in
//                guard let self = self else { return }
//
//                if let decodedGameState = decodedGameState {
//                    self.gameState = decodedGameState
//                }
//
//                self.handleGameSelection(using: conversationManager, conversation: conversation)
//            }
//        } else {
//            presentContentView(conversation: conversation)
//        }
//    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        let conversationManager = ConversationManager(conversation: conversation)
        self.conversationManager = conversationManager

        if let messageURL = conversation.selectedMessage?.url {
            conversationManager.decodeGameState(from: messageURL) { [weak self] decodedGameState in
                guard let self = self else { return }
                if decodedGameState != nil {
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
    
    func updateAndSendGameState(completion: @escaping () -> Void) {
         guard let conversation = activeConversation else {
             completion()
             return
         }
         let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
         let layout = MSMessageTemplateLayout()
         layout.caption = "Your turn!"
         message.layout = layout

         var components = URLComponents()
         components.queryItems = [
             URLQueryItem(name: "gameType", value: String(gameState.gameType ?? "beef_wellington")),
             URLQueryItem(name: "player1Score", value: String(gameState.player1Score)),
             URLQueryItem(name: "player2Score", value: String(gameState.player2Score)),
             URLQueryItem(name: "player1Played", value: String(gameState.player1Played)),
             URLQueryItem(name: "player2Played", value: String(gameState.player2Played)),
             URLQueryItem(name: "currentPlayer", value: gameState.currentPlayer == "player1" ? "player2" : "player1")
         ]

         message.url = components.url

         conversation.insert(message) { [weak self] error in
             if let error = error {
                 print("Error sending message: \(error.localizedDescription)")
             } else {
                 DispatchQueue.main.async {
                     completion()
                 }
                 func dismissAllPresentedViewControllers() {
                     self?.dismiss(animated: true, completion: nil)
                 }

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
                        viewModel.showOutcomeView = true
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
                        viewModel.showOutcomeView = true
                    }
                }
                presentPancakeGame(viewModel: viewModel)
            }
        } else {
            presentContentView(conversation: conversation)
        }
    }

    private func presentContentView(conversation: MSConversation) {
        let contentView = ContentView(conversation: conversation)
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
    }

    private func presentOutcomeView(with gameState: GameState) {
        let viewModel = PancakeGameViewModel(gameState: gameState, messagesViewController: self)
        let gameOutcomeView = GameOutcomeView(gameState: gameState, viewModel: viewModel)
           let hostingController = UIHostingController(rootView: gameOutcomeView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
        requestPresentationStyle(.compact)
       }

    private func presentSteakGame(viewModel: SteakGameViewModel) {
        let view = SteakSeasoningView(viewModel: viewModel, messagesViewController: self)
        presentView(view)
    }

    private func presentPancakeGame(viewModel: PancakeGameViewModel) {
            let view = CrackEggsView(viewModel: viewModel, messagesViewController: self)
            presentView(view)
        }

        func presentView<T: View>(_ view: T) {
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
