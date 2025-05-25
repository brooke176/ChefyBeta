import SwiftUI

struct PastryRollingView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    @State private var rollCount = 0
    @State private var dragOffset = CGSize.zero
    let requiredRolls = 5
    let rollThresholdUpper = UIScreen.main.bounds.height / 3
    let rollThresholdLower = UIScreen.main.bounds.height * 1.75 / 3
    @State private var lastDirectionUp = false
    @State private var crossedThreshold = false

    var body: some View {
        ZStack {
            Image("dough")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            thresholdIndicators

            Image("rollingpin")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 250)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            withAnimation {
                                self.dragOffset = gesture.translation
                            }
                            self.updateRollingCount(gesture: gesture)
                        }
                        .onEnded { _ in
                            self.resetAfterDrag()
                        }
                )

            VStack {
                rollingInstructions
            }
            .padding()
        }
    }

    private var thresholdIndicators: some View {
        Group {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
                .position(x: UIScreen.main.bounds.width / 2, y: rollThresholdUpper)

            Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
                .position(x: UIScreen.main.bounds.width / 2, y: rollThresholdLower)
        }
    }

    private var rollingInstructions: some View {
        VStack {
            PastryInstructionText(rollCount: rollCount, requiredRolls: requiredRolls)
                .padding()
                .background(Color.white.opacity(0.8))
                .foregroundColor(Color.black)
                .font(.headline)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
                .padding(.vertical, 5)
            Spacer()
            if rollCount >= requiredRolls {
                Button("Finish rolling dough") {
                    viewModel.currentStage = .prepPastry
                    viewModel.showDoughPrepView = true
                }
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
            }
            ProgressView(value: Double(rollCount), total: Double(requiredRolls))
                .frame(height: 20)
                .padding()
        }
    }

    private func updateRollingCount(gesture: DragGesture.Value) {
        let currentYPosition = UIScreen.main.bounds.height / 2 + gesture.translation.height
        let movingUp = gesture.translation.height < 0
        if movingUp != lastDirectionUp {
            crossedThreshold = false
        }
        if !crossedThreshold && ((movingUp && currentYPosition <= rollThresholdUpper) || (!movingUp && currentYPosition >= rollThresholdLower)) {
            rollCount += 1
            crossedThreshold = true
        }
        lastDirectionUp = movingUp
    }

    private func resetAfterDrag() {
        dragOffset = .zero
        lastDirectionUp = false
        crossedThreshold = false
    }
}

struct PastryInstructionText: View {
    let rollCount: Int
    let requiredRolls: Int

    var body: some View {
        Text(rollCount < requiredRolls ? "Roll out the pastry dough. Rolls: \(rollCount)/\(requiredRolls)" : "Ready to bake!")
    }
}



//    struct PastryButtons: View {
//        @ObservedObject var viewModel: SteakGameViewModel
//
//        var body: some View {
//            VStack {
//                Button("Finish rolling dough", action: viewModel.serveMushrooms)
//                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
//                ProgressBar(progress: viewModel.mushroomCookingProgress).frame(height: 20).padding()
//            }
//        }
//    }
