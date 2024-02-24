import Foundation
import SwiftUI

struct CrackEggsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel

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
                    Rectangle()
                        .fill(Color.red.opacity(0.003))
                        .frame(width: 200, height: 150)
                        .position(x: UIScreen.main.bounds.width / 1.6, y: UIScreen.main.bounds.height / 2.5)
                        .onTapGesture { _ in
                            let tapLocation = CGPoint(x: 100, y: 100)
                            viewModel.crackPickedEgg(at: tapLocation)
                        }

                    ForEach(0..<viewModel.eggs.count, id: \.self) { index in
                        if viewModel.eggs[index].state == .whole {
                            Image(viewModel.eggs[index].imageName)
                                .resizable()
                                .frame(width: 20, height: 30)
                                .offset(x: 140, y: 235)
                                .padding()
                                .onTapGesture {
                                    viewModel.pickUpEgg(at: index)
                                }
                        }
                    }
                }
                Spacer()
                VStack {
                    ForEach(0..<viewModel.eggs.count, id: \.self) { index in
                        if viewModel.eggs[index].state == .cracked, let position = viewModel.eggs[index].position {
                            Image(viewModel.eggs[index].imageName)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .position(x: 190, y: -80)
                                .animation(.easeInOut, value: viewModel.eggs[index].position)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            viewModel.eggs[index].state = .exploded
                                        }
                                    }
                                }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 200, alignment: .trailing)
                VStack {
                    Button("Mix eggs", action: viewModel.startMixing)
                        .buttonStyle(GameButtonStyle(backgroundColor: viewModel.eggsCracked >= 5 ? .blue : .gray))
//                        .disabled(viewModel.eggsCracked >= 5)
                }
            }
        }
        .onAppear {
            viewModel.resetEggs()
        }
        .sheet(isPresented: $viewModel.showMixingView) {
            MeasuringIngredientsView(viewModel: viewModel)
        }
    }
}
