import SwiftUI
import Combine

struct SauteMushroomsView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    // Removed old unused constants: totalCookingTime, stirInterval, colorChangeInterval

    @State private var showSmoke: Bool = false // For smoke animation

    var body: some View {
        ZStack {
            Image("stovie2") // Background image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack { // Main VStack for layout
                Spacer() // Pushes content to center/bottom

                MushroomInstructionText(viewModel: viewModel)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.brown.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                    )
                    .padding(.vertical, 20) // Increased vertical padding

                // Mushroom display area
                ZStack {
                    Image("mushrooms")
                        .resizable()
                        .scaledToFit()
                        .colorMultiply(viewModel.mushroomColor) // Driven by ViewModel
                        .frame(width: 150, height: 150) // Slightly larger mushrooms
                        .rotationEffect(Angle(degrees: Double(viewModel.rotationDegrees)))
                        // .animation(.easeInOut, value: viewModel.rotationDegrees) // Animation for rotation
                        .onTapGesture {
                            viewModel.stirMushrooms()
                        }

                    // Smoke effect
                    if showSmoke {
                        ForEach(0..<5) { _ in // 5 smoke particles
                            Circle()
                                .fill(Color.gray.opacity(Double.random(in: 0.2...0.5)))
                                .frame(width: CGFloat.random(in: 15...30), height: CGFloat.random(in: 15...30))
                                .offset(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -60 ... -30))
                                .animation(.linear(duration: Double.random(in: 1...2)).repeatForever(autoreverses: false)
                                           .delay(Double.random(in: 0...1)), value: showSmoke)
                                .transition(.opacity)
                        }
                    }
                }
                .onChange(of: viewModel.mushroomBurnLevel) { newBurnLevel in
                     // Trigger smoke based on burn level
                     showSmoke = newBurnLevel > 0.4 // Threshold for showing smoke
                }
                .padding(.bottom, 30) // Space between mushrooms and buttons
                
                Spacer() // Pushes buttons to the bottom if VStack is too large

                ShroomButtons(viewModel: viewModel)
                    .padding(.bottom, 40) // Padding for bottom buttons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack takes available space
        }
    }

    struct MushroomInstructionText: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            Text(instructionText)
                .multilineTextAlignment(.center)
        }

        private var instructionText: String {
            let progress = viewModel.mushroomCookingProgress
            let burnLevel = viewModel.mushroomBurnLevel
            let timeSinceStir = viewModel.timeSinceLastStir
            
            let stirThreshold = viewModel.STIR_INTERVAL_THRESHOLD
            let perfectStart = viewModel.PERFECT_MUSHROOM_WINDOW_START
            let perfectEnd = viewModel.PERFECT_MUSHROOM_WINDOW_END
            let highBurnThreshold = viewModel.MAX_ALLOWED_BURN_LEVEL * 0.8 // e.g. 80% of max burn
            let moderateBurnThreshold = viewModel.MAX_ALLOWED_BURN_LEVEL * 0.4 // e.g. 40% of max burn

            if burnLevel >= highBurnThreshold {
                return "Mushrooms are burning badly! Finish now if you can!"
            } else if burnLevel > moderateBurnThreshold {
                return "Mushrooms are starting to burn! Stir them frequently!"
            } else if timeSinceStir > stirThreshold * 0.75 { // More urgent stir warning
                return "Stir the mushrooms now to prevent burning!"
            } else if timeSinceStir > stirThreshold * 0.5 {
                 return "Don't forget to stir the mushrooms."
            } else if progress < perfectStart {
                return "Sautéing mushrooms... Keep stirring occasionally."
            } else if progress <= perfectEnd {
                return "Looking good! They're in the perfect window. Finish soon!"
            } else if progress > perfectEnd {
                return "A bit overcooked, finish up quickly!"
            } else {
                return "Sautéing mushrooms..." // Default
            }
        }
    }

    struct ShroomButtons: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Finish cooking shrooms") {
                    // ViewModel's endCookingMushrooms should handle setting currentStage and showDoughRollingView
                    viewModel.endCookingMushrooms()
                }
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                .disabled(viewModel.isMushroomsCooking == false && viewModel.mushroomCookingProgress > 0) // Example: disable if already ended but not reset

                ProgressBar(
                    progress: viewModel.mushroomCookingProgress,
                    perfectWindowStart: viewModel.PERFECT_MUSHROOM_WINDOW_START,
                    perfectWindowEnd: viewModel.PERFECT_MUSHROOM_WINDOW_END
                )
                .frame(height: 20)
                .padding()
            }
        }
    }
}
