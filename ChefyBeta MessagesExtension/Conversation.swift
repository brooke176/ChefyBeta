import Foundation
import Messages

class ConversationManager {
    var conversation: MSConversation

    init(conversation: MSConversation) {
        self.conversation = conversation
    }

    // Add methods to manage your conversation here, such as sending messages
    func sendMessage(with message: MSMessage) {
        // Implementation to send a message using self.conversation
    }
}

extension ConversationManager {
    func sendGameState(score: Int, completion: ((Error?) -> Void)? = nil) {
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = "Steak Cooking Game"
        layout.subcaption = "Score: \(score)"
        message.layout = layout
        
        // Optionally, encode more game state in the message URL
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "score", value: "\(score)")
        ]
        message.url = components.url
        
        conversation.insert(message) { error in
            completion?(error)
        }
    }
}

