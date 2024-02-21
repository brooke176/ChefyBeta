import Foundation
import SwiftUI

struct SteakSeasoningView: View {
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
        ZStack {
            Image("seasonSteakBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                SeasoningInstructionText(gameEnded: viewModel.gameEnded, isCooking: viewModel.isCooking, steakFlipped: viewModel.steakFlipped, cookingProgress: viewModel.cookingProgress, seasoning: viewModel.seasoning, gameState: viewModel.gameState)
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
                SteakView(steakFlipped: viewModel.steakFlipped, isCooking: viewModel.isCooking, seasoningGraphics: viewModel.seasoningGraphics, viewModel: viewModel)
                ActionButtonView(viewModel: viewModel)
                    .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $viewModel.showOutcomeView) {
            GameOutcomeView(gameState: viewModel.gameState)
        }
        .sheet(isPresented: $viewModel.showCookingView) {
            SteakView(steakFlipped: viewModel.steakFlipped, isCooking: viewModel.isCooking, seasoningGraphics: viewModel.seasoningGraphics, viewModel: viewModel)
        }
    }
}

struct SeasoningInstructionText: View {
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
        if seasoning.frontSalt < minSeasoningAmount || seasoning.frontPepper < minSeasoningAmount {
            return "Season the steak"
        } else if steakFlipped && seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount  {
            return "Flip the steak"
        } else if !steakFlipped && (seasoning.backSalt < minSeasoningAmount || seasoning.backPepper < minSeasoningAmount) {
            return "Season the back side of the steak"
        } else {
            return "Cook the steak!"
        }
    }
}

struct SteakView: View {
    var steakFlipped: Bool
    var isCooking: Bool
    var seasoningGraphics: [SeasoningGraphic]
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
                ZStack(alignment: .center) {
                    Image("steakie")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 175, height: 175)
                        .offset(x: 45, y: -150)
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                        .rotation3DEffect(.degrees(steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeInOut(duration: 0.5), value: steakFlipped)
                        .onTapGesture {
                            viewModel.steakFlipped.toggle()
                        }
        
                    ForEach(seasoningGraphics.filter { $0.side == (steakFlipped ? .front : .back) }) { graphic in
                        Circle()
                            .fill(graphic.color)
                            .frame(width: 4, height: 4)
                            .position(graphic.position)
                    }
        
                    Rectangle()
                        .fill(Color.red.opacity(0.01))
                        .frame(width: 80, height: 90)
                        .offset(x: -105, y: -62)
                        .onTapGesture {
                            viewModel.addSeasoningGraphics(type: .salt)
                        }
        
                    Rectangle()
                        .fill(Color.blue.opacity(0.01))
                        .frame(width: 80, height: 80)
                        .offset(x: 135, y: 137)
                        .onTapGesture {
                            viewModel.addSeasoningGraphics(type: .pepper)
                        }
                }
    }
}

struct ActionButtonView: View {
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
        VStack {
            Button("Start Cooking") {
                viewModel.startCooking()
                viewModel.showCookingView = true
            }
            .buttonStyle(GameButtonStyle(backgroundColor: .green))
        }
    }
}
