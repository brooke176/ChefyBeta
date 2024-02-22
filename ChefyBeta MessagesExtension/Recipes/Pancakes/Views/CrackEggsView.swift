import Foundation
import SwiftUI

struct CrackEggsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel

    var body: some View {
        ZStack {
            Image("mixing_bowls")
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

                Spacer()

                Rectangle()
                    .fill(Color.red.opacity(0.0001))
                    .frame(width: 250, height: 200)
                    .offset(x: 0, y: -150)
                    .onDrop(of: [.plainText], isTargeted: nil) { _, _ in
                        viewModel.handleDrop()
                        return true
                    }
                Spacer().frame(height: 100)
            }

            DraggableEgg(viewModel: viewModel)
            VStack {
                Spacer()
                EggButtons(viewModel: viewModel)
            }
        }
    }
}

struct DraggableEgg: View {
    @ObservedObject var viewModel: PancakeGameViewModel

    var body: some View {
        let imageName = viewModel.currentEggState == .whole ? "egg" :
            viewModel.currentEggState == .cracked ? "cracked_eggy" : "exploded_egg"

        Image(imageName)
            .resizable()
            .frame(width: 50, height: 70)
            .offset(x: -50, y: 0)
            .onDrag {
                viewModel.startDrag()
                return NSItemProvider(object: "egg" as NSString)
            }
    }
}

struct EggButtons: View {
    @ObservedObject var viewModel: PancakeGameViewModel

    var body: some View {
        VStack {
            Button("Mix eggs", action: viewModel.startMixing)
                .buttonStyle(GameButtonStyle(backgroundColor: .blue))
//            ProgressBar(progress: viewModel.wellingtonCookingProgress).frame(height: 20).padding()
        }
    }
}
