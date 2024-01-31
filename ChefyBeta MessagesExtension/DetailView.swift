import SwiftUI
import Messages

struct DetailView: View {
    let item: ImageItem
    var conversation: MSConversation?
    @Environment(\.presentationMode) var presentationMode
    @State private var isMessageReadyToSend = false

    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .border(Color.black, width: 1)
            
            Text(item.label)
                .font(.caption)
                .foregroundColor(.black)

            if isMessageReadyToSend {
                Button("Send \(item.label)") {
                    sendMessage()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button("Play \(item.label)") {
                    prepareMessage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    private func prepareMessage() {
        guard let conversation = conversation else {
            print("Conversation is nil")
            return
        }
        print("conv1", conversation)

        let session = conversation.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)

        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: item.imageName) // Dynamic game icon based on selected item
        layout.caption = "Let's play \(item.label)!"
        message.layout = layout

        // Insert the message into the conversation
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error.localizedDescription)")
            } else {
                print("Message prepared successfully")
                // No need to dismiss the view, as the user needs to send the message manually
            }
        }
        print("conv2", conversation)
        isMessageReadyToSend = true
    }

    private func sendMessage() {
        guard let conversation = conversation else {
            print("Conversation is nil")
            return
        }

        let session = conversation.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)

        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: item.imageName) // Dynamic game icon based on selected item
        layout.caption = "Let's play \(item.label)!"
        message.layout = layout

        // Insert the message into the conversation
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
