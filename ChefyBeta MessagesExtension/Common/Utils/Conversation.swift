import Foundation
import Messages

class ConversationManager {
    weak var activeConversation: MSConversation?
       var onInvitationSent: (() -> Void)? // Add a callback property
    init(conversation: MSConversation?) {
        self.activeConversation = conversation
    }

//        func sendGameInvitation(completion: @escaping () -> Void) {
//            guard let conversation = activeConversation else { return }
//            
//            let session = MSSession()
//            let message = MSMessage(session: session)
//            let layout = MSMessageTemplateLayout()
//            layout.caption = "Let's play Steak Game!"
//            layout.subcaption = "Tap to join!"
//            message.layout = layout
//            
//            if let url = URL(string: "https://example.com/game_invitation?game=steak") {
//                message.url = url
//            }
//            
//            conversation.insert(message) { error in
//                if let error = error {
//                    print("Error sending game invitation: \(error.localizedDescription)")
//                }
//                completion()
//            }
//        }

//    func parseGameState(from message: MSMessage) -> GameState? {
//        guard let messageURL = message.url,
//              let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
//              let queryItems = urlComponents.queryItems else { return nil }
//        
//        var gameState = GameState()
//        for item in queryItems {
//            switch item.name {
//            case "player1Score":
//                gameState.player1Score = Int(item.value ?? "0") ?? 0
//            case "player2Score":
//                gameState.player2Score = Int(item.value ?? "0") ?? 0
//            case "gameStatus":
//                gameState.gameStatus = item.value ?? "waitingForPlayer1"
//            default:
//                break
//            }
//        }
//        return gameState
//    }
}
