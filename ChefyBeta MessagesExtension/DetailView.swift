import SwiftUI
import Messages

struct DetailView: View {
    let item: ImageItem
    var conversation: MSConversation?
    @Environment(\.presentationMode) var presentationMode
    @State private var isMessageReadyToSend = false
    @State private var showingGameView = false // State to control GameView presentation

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

            if item.label == "Cheeseburger" {
                Button(action: {
                    showingGameView = true // Set to true to show GameView
                }) {
                    Text("Play \(item.label)")
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity) // Make the button width flexible
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5) // Add a shadow for depth
                }
                .padding(.bottom, 10) // Add some padding below the button if needed
            } else {
                Button("Send \(item.label)") {
                    if let conversation = conversation {
                        MessageHandler.insertImage(item: item, into: conversation) { error in
                            if let error = error {
                                print("Error inserting message: \(error.localizedDescription)")
                            } else {
                                // Optionally dismiss the view or provide feedback that the message was sent successfully
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showingGameView) {
            // Assuming GameView() is correctly defined elsewhere
            GameView()
        }
    }
}
