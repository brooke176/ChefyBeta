import Foundation
import SwiftUI

struct CrackEggsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    var messagesViewController: MessagesViewController
    var gameState: GameState = GameState()
    
    var body: some View {
        ZStack {
            Image("eggbackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .offset(x: -25, y: 0)
            
            VStack {
                Text("Crack \(viewModel.eggsToCrack) Eggs!")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Text("Eggs Cracked: \(viewModel.eggsCracked)/\(viewModel.eggsToCrack)")
                    .font(.subheadline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                ZStack {
                    ForEach(viewModel.eggs) { egg in
                        if egg.state == .whole {
                            Image(egg.imageName)
                                .resizable()
                                .frame(width: 40, height: 50)
                                .position(egg.position ?? CGPoint(x: 150, y: 0))
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            viewModel.updateEggPosition(id: egg.id, newPosition: gesture.location)
                                        }
                                        .onEnded { gesture in
                                            let speed = gesture.predictedEndLocation.y - gesture.startLocation.y
                                            viewModel.handleEggDrop(eggId: egg.id, atLocation: gesture.location, withSpeed: speed)
                                        }
                                )
                        } else if egg.state == .cracked || egg.state == .exploded {
                            Image(egg.imageName)
                                .resizable()
                                .frame(width: 80, height: 70)
                                .position(egg.position ?? CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.eggs.removeAll { $0.id == egg.id }
                                    }
                                }
                        }
                    }
                }
                    VStack {
                        Button("Mix eggs") {
                            viewModel.currentStage = .measureIngredients
                        }
                        .buttonStyle(GameButtonStyle(backgroundColor: viewModel.eggsCracked >= 5 ? .blue : .gray))
                    }
            }
        }
        .onAppear {
            viewModel.resetEggs()
        }
        
        .sheet(item: $viewModel.currentStage, onDismiss: {
        }) { stage in
            switch stage {
            case .crackEggs:
                CrackEggsView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .measureIngredients:
                MeasuringIngredientsView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .cookPancakes:
                CookPancakesView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .outcome:
                GameOutcomeView(gameState: viewModel.gameState, viewModel: viewModel)
            }
        }
        
    }
}
