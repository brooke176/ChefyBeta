import Foundation
import Messages

class ConversationManager {
    weak var activeConversation: MSConversation?
    
    init(conversation: MSConversation?) {
        self.activeConversation = conversation
    }
    
    func sendGameState(player1Score: Int, player2Score: Int, gameStatus: String, completion: @escaping (Error?) -> Void) {
        guard let conversation = activeConversation else {
            completion(NSError(domain: "ConversationManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Active conversation not found."]))
            return
        }
        
        let session = conversation.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = "Steak Cooking Challenge!"
        message.layout = layout
        
        // Encode the game state into the message URL
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "player1Score", value: String(player1Score)),
            URLQueryItem(name: "player2Score", value: String(player2Score)),
            URLQueryItem(name: "gameStatus", value: gameStatus)
        ]
        
        message.url = components.url
        
        // Send the message
        conversation.insert(message) { error in
            completion(error)
        }
    }
    
    func parseGameState(from message: MSMessage) -> GameState? {
        guard let messageURL = message.url,
              let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else { return nil }
        
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
}
