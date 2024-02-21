import SwiftUI
import Combine

struct SauteMushroomsView: View {
    @ObservedObject var viewModel: SteakGameViewModel

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
                Spacer()
                ShroomButtons(viewModel: viewModel)
            }}
        .onAppear { viewModel.startCookingMushrooms() }
        .onDisappear { viewModel.endCookingMushrooms() }
        .sheet(isPresented: $viewModel.showOutcomeView) {
            GameOutcomeView(gameState: viewModel.gameState)
        }
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
                Button("Finish cooking shrooms", action: viewModel.serveMushrooms)
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                ProgressBar(progress: viewModel.mushroomCookingProgress).frame(height: 20).padding()
            }
        }
    }
}
