import SwiftUI
import Combine

struct SauteMushroomsView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    let totalCookingTime = 15
    let stirInterval = 3
    let colorChangeInterval = 4

    var body: some View {
        ZStack {
            Image("stovie2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            Image("mushrooms")
                .resizable()
                .scaledToFit()
                .colorMultiply(viewModel.mushroomColor)
                .frame(width: 100, height: 100)
                .offset(x: 45, y: 0)
                .rotationEffect(Angle(degrees: Double(viewModel.rotationDegrees)))
                .animation(.easeInOut)
                .onTapGesture {
                    viewModel.stirMushrooms()
                }
            VStack {
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
                        .padding(.vertical, 5)
                    Spacer()
                    ShroomButtons(viewModel: viewModel)
            }}
    }

    struct MushroomInstructionText: View {
        @ObservedObject var viewModel: SteakGameViewModel
        let maxCookingProgress = 0.6

        var body: some View {
            Text(instructionText)
        }

        private var instructionText: String {
            if viewModel.mushroomCookingProgress < maxCookingProgress {
                return "Keep stirring the mushrooms."
            } else {
                return "Serve the mushrooms!"
            }
        }
    }

    struct ShroomButtons: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Finish cooking shrooms") {
                    viewModel.currentStage = .rollPastry
                    viewModel.showDoughRollingView = true
                }
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                ProgressBar(progress: viewModel.mushroomCookingProgress).frame(height: 20).padding()
            }
        }
    }
}
