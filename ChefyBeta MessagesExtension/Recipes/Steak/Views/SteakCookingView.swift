import Foundation
import SwiftUI

struct SteakCookingView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            Image("stovie2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                // Pass the whole viewModel to InstructionText
                InstructionText(viewModel: viewModel)
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
                // Pass the whole viewModel to SteakCookView
                SteakCookView(viewModel: viewModel)
                    .padding(.bottom, 50) // Adjusted padding
                ActionButtonsView(viewModel: viewModel)
                Spacer()
            }
        }
    }
    
    struct InstructionText: View {
        @ObservedObject var viewModel: SteakGameViewModel
        
        var body: some View {
            Text(instructionText)
        }
        
        private var instructionText: String {
            if viewModel.gameEnded {
                // Existing game end logic - seems fine
                if viewModel.gameState.player2Score != 0 {
                    if viewModel.gameState.player1Score > viewModel.gameState.player2Score {
                        return "You won! 🎉"
                    } else if viewModel.gameState.player1Score < viewModel.gameState.player2Score {
                        return "You lost. Try again!"
                    } else {
                        return "It's a tie!"
                    }
                } else {
                    return "Waiting for opponent..."
                }
            } else if viewModel.flipNeeded {
                return "Flip the steak now!"
            } else if viewModel.cookingProgress < viewModel.PERFECT_SEAR_WINDOW_START {
                return "Searing steak..."
            } else if viewModel.cookingProgress <= viewModel.PERFECT_SEAR_WINDOW_END {
                return "Perfect sear! Serve it now!"
            } else if viewModel.cookingProgress > viewModel.PERFECT_SEAR_WINDOW_END {
                return "A bit too long, serve it!"
            } else {
                return "Keep cooking..." // Default fallback
            }
        }
    }
    
    
    struct SteakCookView: View {
        @ObservedObject var viewModel: SteakGameViewModel
        @State private var isPulsing: Bool = false // For flip cue
        
        var body: some View {
            ZStack(alignment: .center) {
                Image("steakie")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180) // Slightly larger for better visual
                    // Apply browning effect based on cookingProgress
                    .colorMultiply(Color(red: 1.0, green: 1.0 - (viewModel.cookingProgress * 0.6), blue: 1.0 - (viewModel.cookingProgress * 0.8))) // Darkens by reducing green/blue
                    .rotation3DEffect(.degrees(viewModel.steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.steakFlipped)
                    .scaleEffect(isPulsing ? 1.05 : 1.0) // Pulsing effect
                    .onTapGesture {
                        viewModel.flipSteak() // ViewModel handles flipNeeded logic
                    }
                    .onChange(of: viewModel.flipNeeded) { newValue in
                        if newValue {
                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.1)) { // Stop pulsing quickly
                                isPulsing = false
                            }
                        }
                    }

                if viewModel.flipNeeded {
                     Image(systemName: "arrow.triangle.2.circlepath.circle.fill") // Example flip icon
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .offset(y: -100) // Position above the steak
                        .transition(.scale.combined(with: .opacity))
                         .animation(.easeInOut, value: viewModel.flipNeeded)
                }
                
                // Seasoning graphics (if any should be visible on the pan, less likely here)
                // ForEach(viewModel.seasoningGraphics.filter { $0.side == (viewModel.steakFlipped ? .back : .front) }) { graphic in
                //     Circle()
                //         .fill(graphic.color)
                //         .frame(width: 4, height: 4)
                //         .position(graphic.position) // Ensure positioning is correct for this view
                // }
            }
            .frame(height: 200) // Give ZStack a defined height for positioning flip icon
        }
    }
    
    struct ActionButtonsView: View {
        @ObservedObject var viewModel: SteakGameViewModel
        
        var body: some View {
            VStack {
                Button("Serve Steak") {
                    // viewModel.currentStage = .sauteMushrooms // This is handled by serveSteak() in ViewModel
                    viewModel.serveSteak()
                }
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                .disabled(viewModel.gameEnded) // Disable if game ended

                // Pass window parameters to ProgressBar
                ProgressBar(
                    progress: viewModel.cookingProgress,
                    perfectWindowStart: viewModel.PERFECT_SEAR_WINDOW_START,
                    perfectWindowEnd: viewModel.PERFECT_SEAR_WINDOW_END
                )
                .frame(height: 20)
                .padding()
            }
        }
    }
    
}
