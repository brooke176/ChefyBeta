import Foundation
import SwiftUI

struct SteakCookingView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    
    var body: some View {
        ZStack {
            Image("stovie2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                InstructionText(gameEnded: viewModel.gameEnded, isCooking: viewModel.isCooking, steakFlipped: viewModel.steakFlipped, cookingProgress: viewModel.cookingProgress, seasoning: viewModel.seasoning, gameState: viewModel.gameState)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                    )
                    .padding(.vertical, 5)
                Spacer()
                SteakCookView(steakFlipped: viewModel.steakFlipped, isCooking: viewModel.isCooking, seasoningGraphics: viewModel.seasoningGraphics, viewModel: viewModel)
                    .padding(.bottom, 200)
                ActionButtonsView(viewModel: viewModel)
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showMushroomView) {
            SauteMushroomsView(viewModel: viewModel)
        }
    }
    
    struct InstructionText: View {
        var gameEnded: Bool
        var isCooking: Bool
        var steakFlipped: Bool
        var cookingProgress: Double
        var seasoning: SteakSeasoning
        var gameState: GameState
        
        private let minSeasoningAmount: Double = 0.6
        private let maxSeasoningAmount = 3.0
        private let perfectSeasoningRange = 0.6...1.5
        private let maxCookingProgress = 1.0
        
        var body: some View {
            Text(instructionText)
        }
        
        private var instructionText: String {
            if gameEnded {
                if gameState.player2Score != 0 {
                    if gameState.player1Score > gameState.player2Score {
                        return "You won! 🎉"
                    } else if gameState.player1Score < gameState.player2Score {
                        return "You lost. Try again!"
                    } else {
                        return "It's a tie!"
                    }
                } else {
                    return "Waiting for opponent..."
                }}
            else if cookingProgress < 0.6 {
                return "Keep cooking..."
            } else {
                return "Serve the steak"
            }
        }
    }
    
    
    struct SteakCookView: View {
        var steakFlipped: Bool
        var isCooking: Bool
        var seasoningGraphics: [SeasoningGraphic]
        @ObservedObject var viewModel: SteakGameViewModel
        
        var body: some View {
            ZStack(alignment: .center) {
                Image("steakie")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 155, height: 155)
                    .offset(x: 70, y: -135)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .rotation3DEffect(.degrees(steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeInOut(duration: 0.5), value: steakFlipped)
                    .onTapGesture {
                        viewModel.steakFlipped.toggle()
                    }
                
                ForEach(seasoningGraphics.filter { $0.side == (steakFlipped ? .back : .front) }) { graphic in
                    Circle()
                        .fill(graphic.color)
                        .frame(width: 4, height: 4)
                        .position(graphic.position)
                }
            }
        }
    }
    
    struct ActionButtonsView: View {
        @ObservedObject var viewModel: SteakGameViewModel
        
        var body: some View {
            VStack {
                Button("Serve Steak", action: viewModel.serveSteak)
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                ProgressBar(progress: viewModel.cookingProgress).frame(height: 20).padding()
            }
        }
    }
    
}
