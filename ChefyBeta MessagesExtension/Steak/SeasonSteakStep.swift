import SwiftUI

struct SeasonSteakStep: View {
    @ObservedObject var viewModel: GameViewModel
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            Image("seasonSteakBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)

            Button(action: searSteak) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 100) // Adjust size to match the steak's area
                    .position(x: 150, y: 200) // Adjust position based on the steak's location
            }

            Button(action: seasonSteak) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 100) // Adjust size to match the steak's area
                    .position(x: 150, y: 200) // Adjust position based on the steak's location
            }
        }
        .onAppear {
            // Setup or initial actions
        }
        .onChange(of: viewModel.gameState) { _ in
            // Handle game state changes
        }
    }
    
    func searSteak() {
        print("Steak was clicked")
    }
    
    func seasonSteak() {
        print("Steak was seasoned")
    }

    // Break down your view into smaller subviews if possible
}

