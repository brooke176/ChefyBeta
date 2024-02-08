import SwiftUI
import Messages

struct ParentView: View {
    @State private var showingCompletedDishView = false
    @State private var playerScore = 0 // Example score, replace with actual logic
    @State private var opponentScore: Int? = nil // Now as a State variable for reactivity
    var conversationManager: ConversationManager // Assuming this is passed to or accessible by ParentView
    
    var body: some View {
        // Your parent view content here...
        
        Button("Show Results") {
            showingCompletedDishView = true
        }
        .sheet(isPresented: $showingCompletedDishView) {
            // Pass opponentScore as a Binding to GameResultView
            GameResultView(conversationManager: conversationManager, playerScore: playerScore, opponentScore: $opponentScore)
        }
    }
    
    // Example function to handle incoming message
    func handleIncomingMessage(_ message: MSMessage) {
        // Parse message to extract opponent's score and update opponentScore
        // This logic depends on how you structure the incoming message
        if let messageURL = message.url,
           let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
           let queryItems = urlComponents.queryItems {
            for item in queryItems {
                if item.name == "playerScore", let value = item.value, let score = Int(value) {
                    DispatchQueue.main.async {
                        self.opponentScore = score
                    }
                }
            }
        }
    }
}

struct GameResultView: View {
    var conversationManager: ConversationManager
    var playerScore: Int
    @Binding var opponentScore: Int? // Change to a binding to react to updates
    @State private var gameStatusMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Your Score: \(playerScore)")
                .font(.title)
                .padding()
            
            if let opponentScore = opponentScore {
                // If the opponent has already played, show the scores and determine the winner
                Text("Opponent's Score: \(opponentScore)")
                    .font(.title2)
                    .padding()
                Text(determineWinner(playerScore: playerScore, opponentScore: opponentScore))
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            } else {
                // Opponent hasn't played yet, show waiting message
                Text("Waiting for opponent...")
                    .font(.title2)
                    .padding()
                
                Button("Send Score and Wait") {
                    // Logic to send score to opponent
                    sendScore()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            // Set initial message based on whether opponent has played
            gameStatusMessage = opponentScore == nil ? "Waiting for opponent..." : determineWinner(playerScore: playerScore, opponentScore: opponentScore!)
        }
    }

    private func sendScore() {
        guard let conversation = conversationManager.activeConversation else { return }
        let gameState = GameState()

        // Assuming you have a way to uniquely identify players, you might need to adjust how you determine player1 or player2
        let playerScore = gameState.player1Score // Or player2Score, depending on the player
        
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = "My Score: \(playerScore)"
        message.layout = layout
        
        // Adjust URL to include player score and turnTaken flag
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "playerScore", value: String(playerScore)),
            URLQueryItem(name: "turnTaken", value: String(gameState.turnTaken))
        ]
        message.url = components.url
        
        conversation.insert(message) { error in
            if let error = error {
                print("Error sending score: \(error.localizedDescription)")
            } else {
                // Optionally, navigate or change UI state to indicate the score was sent
            }
        }
    }
    
    private func determineWinner(playerScore: Int, opponentScore: Int) -> String {
        if playerScore > opponentScore {
            return "You win!"
        } else if playerScore < opponentScore {
            return "Opponent wins."
        } else {
            return "It's a tie!"
        }
    }
}
