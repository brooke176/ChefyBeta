import SwiftUI

struct OvenCookingView: View {
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
                    // Updated Instruction Text
                    Text(instructionText)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(Color.black)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                        )
                        .padding(.vertical, 5)
                    
                    // Use the local SteakCookView, passing only necessary ViewModel properties for Wellington
                    SteakCookView(wellingtonProgress: viewModel.wellingtonCookingProgress, viewModel: viewModel) // Pass viewModel for constants
                        .padding(.bottom, 50) // Adjusted padding
                    
                    OvenButtons(viewModel: viewModel)
                        .padding(.bottom, 40) // Added padding
                }
            }
    }

    // Computed property for dynamic instruction text
    private var instructionText: String {
        let progress = viewModel.wellingtonCookingProgress
        let perfectStart = viewModel.PERFECT_WELLINGTON_WINDOW_START
        let perfectEnd = viewModel.PERFECT_WELLINGTON_WINDOW_END

        if progress < perfectStart {
            return "Baking the Beef Wellington..."
        } else if progress <= perfectEnd {
            return "Perfectly golden! Plate it now!"
        } else {
            return "A bit too brown! Plate it quickly!"
        }
    }
    
    // Modified local SteakCookView for Wellington
    struct SteakCookView: View {
        var wellingtonProgress: Double // Use specific progress for Wellington
        @ObservedObject var viewModel: SteakGameViewModel // To access constants if needed for color logic

        var body: some View {
            ZStack(alignment: .center) {
                Image("beef_wellington") // Using existing asset, will simulate rawness with colorMultiply
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150) // Adjusted frame for Wellington
                    .colorMultiply(browningColor(progress: wellingtonProgress))
                    // No rotation or tap gesture for flipping needed
            }
            .frame(height: 200) // Ensure ZStack has a good frame for the image
        }

        private func browningColor(progress: Double) -> Color {
            // Start lighter (less brown), become golden, then darker
            // The base "beef_wellington" image is already cooked, so we adjust from there.
            // This logic might need tweaking based on the actual base image color.
            if progress < viewModel.PERFECT_WELLINGTON_WINDOW_START * 0.5 { // Very early stage, make it look less done
                return Color(red: 0.9, green: 0.8, blue: 0.7) // Paler brown / tan
            } else if progress < viewModel.PERFECT_WELLINGTON_WINDOW_START { // Approaching perfect
                return Color(red: 0.8, green: 0.7, blue: 0.6) // Light-mid brown
            } else if progress <= viewModel.PERFECT_WELLINGTON_WINDOW_END { // Perfect window
                return .white // Use the original image color (assuming it's perfectly golden)
            } else { // Overcooked
                return Color(red: 0.6, green: 0.4, blue: 0.2) // Darker brown
            }
        }
    }
    
    struct OvenButtons: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Plate beef wellington") {
                    // viewModel.currentStage = .outcome // This is handled by endCookingWellington()
                    viewModel.endCookingWellington()
                }
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                .disabled(viewModel.gameEnded || viewModel.isWellingtonCooking == false && viewModel.wellingtonCookingProgress > 0) // Disable if game over or already plated

                ProgressBar(
                    progress: viewModel.wellingtonCookingProgress,
                    perfectWindowStart: viewModel.PERFECT_WELLINGTON_WINDOW_START,
                    perfectWindowEnd: viewModel.PERFECT_WELLINGTON_WINDOW_END
                )
                .frame(height: 20)
                .padding()
            }
        }
    }
}
