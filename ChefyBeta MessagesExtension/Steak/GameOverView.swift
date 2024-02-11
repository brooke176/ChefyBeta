import SwiftUI

struct GameOverView: View {
    @Binding var gameState: GameState // Use Binding if changes to gameState should reflect back to the parent view
    var conversationManager: ConversationManager
    var messagesViewController: MessagesViewController // Add reference to MessagesViewController

    var body: some View {
        NavigationView {
            VStack {
                if gameState.currentPlayer == "player1" && !gameState.player1Played {
                    NavigationLink(destination: SteakGameView(gameState: $gameState, messagesViewController: messagesViewController)) {
                        Text("Play your turn, Player 1")
                    }
                } else if gameState.currentPlayer == "player2" && !gameState.player2Played {
                    NavigationLink(destination: SteakGameView(gameState: $gameState, messagesViewController: messagesViewController)) {
                        Text("Play your turn, Player 2")
                    }
                } else {
                    Text(gameState.player1Played && gameState.player2Played ? "Game Over" : "Waiting for other player...")
                    if gameState.player1Played && gameState.player2Played {
                        Text("Player 1 Score: \(gameState.player1Score), Player 2 Score: \(gameState.player2Score)")
                        Text(gameState.player1Score > gameState.player2Score ? "Player 1 Wins!" : gameState.player2Score > gameState.player1Score ? "Player 2 Wins!" : "It's a Tie!")
                    }
                }
            }
            .navigationTitle("Steak Seasoning Game")
        }
    }
}
