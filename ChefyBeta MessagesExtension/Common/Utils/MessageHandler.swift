import Foundation
import Messages
import UIKit

class MessageHandler {

    static func insertImage(item: ImageItem, into conversation: MSConversation, completionHandler: ((NSError?) -> Void)?) {
        guard let image = UIImage(named: item.imageName) else {
            print("Image not found")
            return
        }

        let layout = MSMessageTemplateLayout()
        layout.image = image

        let message = MSMessage()
        message.layout = layout

        conversation.insert(message) { error in
            completionHandler?(error as NSError?)
        }
    }

    static func sendMessage(invite: String, conversation: MSConversation?) {
        guard let conversation = conversation else { return }

        let layout = MSMessageTemplateLayout()
        layout.caption = "Let's play Steak Game!"
        layout.subcaption = "Tap to start playing."

        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        message.layout = layout

        let components = URLComponents()
        message.url = components.url

        conversation.insert(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                // Dismiss your view or notify the user of success
            }
        }
    }
}
