import Foundation
import SwiftUI

struct PancakeOrder {
    var order: [PancakeType]

    static func generateRandomOrder() -> PancakeOrder {
        let order = [PancakeType.plain, .plain, .blueberry, .blueberry, .blueberry, .chocolateChip].shuffled()
        return PancakeOrder(order: order)
    }
}

struct CookPancakesView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            Image("eggbackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

                Image("plate")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(x: 20, y: -140)

                Image("chocchips")
                    .resizable()
                    .frame(width: 80, height: 60)
                    .offset(x: -130, y: -165)
                    .onDrag {
                        return NSItemProvider(object: NSString(string: "chocolatechips"))
                    }

                Image("blueberry")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .offset(x: 150, y: -175)
                    .onDrag {
                        return NSItemProvider(object: NSString(string: "booberry"))
                    }

                Image("griddle")
                    .resizable()
                    .frame(width: 300, height: 200)
                    .offset(x: 0, y: 110)

                Rectangle()
                    .fill(Color.red.opacity(0.00005))
                    .frame(width: 300, height: 200)
                    .offset(x: 0, y: 100)
                    .onTapGesture {
                        viewModel.pourBatter()
                    }

            InstructionText(order: viewModel.currentOrder)
                .padding()
                .background(Color.white.opacity(0.8))
                .foregroundColor(Color.black)
                .font(.headline)
                .cornerRadius(10)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                )
                .padding(.horizontal, 50)
                .padding(.vertical, 10)
                .padding(.bottom, 40)

                Spacer()

                ForEach(viewModel.pancakes) { pancake in
                    PancakeView(viewModel: viewModel, pancake: pancake)
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
                    viewModel.endTurnForPlayer()
                }) {
                    Text("Serve Pancakes")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }, alignment: .bottom
            )
    }
}

struct InstructionText: View {
    var order: PancakeOrder

    var body: some View {
        let counts = order.order.reduce(into: [:]) { counts, type in counts[type, default: 0] += 1 }
        let instructions = "Cook the following pancakes: \(counts[.plain, default: 0]) plain, \(counts[.blueberry, default: 0]) blueberry, and \(counts[.chocolateChip, default: 0]) chocolate chip."

        return Text(instructions)
    }
}

struct PancakeView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    let pancake: Pancake

    var body: some View {
        ZStack {
                    if pancake.state == .burned {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 50, height: 50)
                    } else {
                        Image(pancakeImageName(for: pancake))
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
           if pancake.type == .blueberry {
                Image("booberry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            } else if pancake.type == .chocolateChip {
                Image("chocolatechips")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
        .rotation3DEffect(.degrees(pancake.hasBeenFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut, value: pancake.hasBeenFlipped)
        .onDrop(of: ["public.text"], delegate: DropViewDelegate(pancakeID: pancake.id, viewModel: viewModel))
    }

    private func pancakeImageName(for pancake: Pancake) -> String {
        switch pancake.state {
        case .batter, .flipped:
            return "rawpancake"
        case .readyToFlip, .done:
            return "cookedpancakecolor"
        case .burned:
            return "burnedpancake"
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let pancakeID: UUID
    var viewModel: PancakeGameViewModel

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.text"]) else { return false }

        let providers = info.itemProviders(for: ["public.text"])
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, _) in
                guard let data = data as? Data, let topping = String(data: data, encoding: .utf8) else { return }
                DispatchQueue.main.async {
                    self.viewModel.addTopping(toPancakeID: self.pancakeID, topping: topping)
                    // Trigger haptic feedback
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                }
            }
        }
        return true
    }
}
