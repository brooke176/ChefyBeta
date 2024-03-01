import Foundation
import SwiftUI

struct CookPancakesView: View {
    @ObservedObject var viewModel: PancakeGameViewModel

    var body: some View {
        ZStack {
            Image("eggbackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
                Image("plate")
                .resizable()
                .frame(width: 100, height: 100)
                .offset(x: 20, y: -130)

            Image("griddle")
                .resizable()
                .frame(width: 300, height: 200)
                .offset(x: 0, y: 110)
            
            Rectangle()
                .fill(Color.red.opacity(0.00001))
                .frame(width: 300, height: 200)
                .offset(x: 0, y: 130)
                .onTapGesture {
                    viewModel.pourBatter()
                }
            
            ForEach(viewModel.pancakes) { pancake in
                PancakeView(pancake: pancake)
                    .position(x: pancake.position.x, y: pancake.position.y)
                    .onTapGesture {
                        if pancake.state == .done {
                            viewModel.moveToPlate(pancakeID: pancake.id)
                        } else if pancake.state == .readyToFlip {
                            viewModel.flipPancake(id: pancake.id)
                        }
                    }
            }
        }
        .overlay(
            Button(action: {
                viewModel.servePancakes()
            }) {
                Text("Serve Pancakes")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }, alignment: .bottom
        )
        .sheet(isPresented: $viewModel.showOutcomeView) {
            GameOutcomeView(gameState: viewModel.gameState)
        }
    }
    
}

struct PancakeView: View {
    let pancake: Pancake

    var body: some View {
        ZStack {
            Image(pancakeImageName(for: pancake))
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
        .rotation3DEffect(
            .degrees(pancake.hasBeenFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut, value: pancake.hasBeenFlipped)
    }
    
    private func pancakeImageName(for pancake: Pancake) -> String {
        switch pancake.state {
        case .batter, .cooking:
            return "rawpancake"
        case .readyToFlip:
            return "cookedpancakecolor"
        case .cooked, .done:
            return "cookedpancakecolor"
        case .burned:
            return "burnedpancake"
        case .flipped:
            return "rawpancake"
        }
    }
}
