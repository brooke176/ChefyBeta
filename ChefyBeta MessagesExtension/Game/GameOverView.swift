import SwiftUI

struct GameOutcomeView: View {
    var gameState: GameState
    @ObservedObject var viewModel: PancakeGameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(gameState.player1Score != 0 && gameState.player2Score != 0 ? "Game Over" : "Waiting for opponent...")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(radius: 10)

            if gameState.player1Score != 0 && gameState.player2Score != 0 {
                outcomeMessage
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)
                    .shadow(radius: 5)
            } else {
                Text("Waiting for opponent...")
                    .foregroundColor(.gray)
                    .italic()
            }

            scoreText("Player 1 Score: \(gameState.player1Score)")
            scoreText("Player 2 Score: \(gameState.player2Score)")

            Button("OK") {
                viewModel.showOutcomeView = false
                viewModel.currentStage = nil
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(8)
            .shadow(radius: 5)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }

    @ViewBuilder
    private var outcomeMessage: some View {
        if let winner = determineWinner(gameState: gameState) {
            Text("\(winner) wins!")
        } else {
            Text("It's a draw!")
        }
    }

    private func scoreText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .padding(5)
    }

    func determineWinner(gameState: GameState) -> String? {
        if gameState.player1Score > gameState.player2Score {
            return "Player 1"
        } else if gameState.player2Score > gameState.player1Score {
            return "Player 2"
        } else {
            return nil
        }
    }
}
