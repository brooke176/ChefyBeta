import SwiftUI

struct GameOutcomeView: View {
    var gameState: GameState

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary) // Adapts to dark or light mode

            if let winner = determineWinner(gameState: gameState) {
                Text("\(winner) wins!")
                    .foregroundColor(.primary) // Adapts to dark or light mode
            } else {
                Text("It's a draw!")
                    .foregroundColor(.primary) // Adapts to dark or light mode
            }

            Text("Player 1 Score: \(gameState.player1Score)")
                .foregroundColor(.primary) // Adapts to dark or light mode
            Text("Player 2 Score: \(gameState.player2Score)")
                .foregroundColor(.primary) // Adapts to dark or light mode

            Button("OK") {
                //
            }
            .foregroundColor(.primary) // Adapts to dark or light mode
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Adapts to dark or light mode
        .cornerRadius(12)
        .shadow(radius: 8)
    }

    func determineWinner(gameState: GameState) -> String? {
        if gameState.player1Score > gameState.player2Score {
            return "Player 1"
        } else if gameState.player2Score > gameState.player1Score {
            return "Player 2"
        } else {
            return nil // It's a draw
        }
    }
}
