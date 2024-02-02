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
}
