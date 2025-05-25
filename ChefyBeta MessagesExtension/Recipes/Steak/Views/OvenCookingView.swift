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
                    SteakCookView(steakFlipped: viewModel.steakFlipped, isCooking: viewModel.isCooking, seasoningGraphics: viewModel.seasoningGraphics, viewModel: viewModel)
                        .padding(.bottom, 200)
                    OvenButtons(viewModel: viewModel)
                        }}
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
            }
        }
    }
    

    struct OvenButtons: View {
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Plate beef wellington") {
                    viewModel.endCookingWellington()
                }
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                ProgressBar(progress: viewModel.wellingtonCookingProgress).frame(height: 20).padding()
            }
        }
    }
}
