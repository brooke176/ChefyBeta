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
                    Text(viewModel.wellingtonCookingProgress <= 0.8 ? "Keep cooking..." : "Plate the beef wellington!")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(5)
                        .shadow(radius: 5)
                    OvenButtons(viewModel: viewModel)
                        }}
//        .sheet(isPresented: $viewModel.showOutcomeView) {
//            GameOutcomeView(gameState: viewModel.gameState, messagesViewController: messagesViewController, viewModel: Pan)
//        }
    }

    struct OvenButtons: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Plate beef wellington", action: viewModel.endCookingWellington)
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                ProgressBar(progress: viewModel.wellingtonCookingProgress).frame(height: 20).padding()
            }
        }
    }
}
