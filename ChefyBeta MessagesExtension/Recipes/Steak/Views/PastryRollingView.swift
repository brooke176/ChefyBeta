import SwiftUI
import Combine

struct PastryRollingView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    @State private var rollCount = 0
    @State private var dragOffset = CGSize.zero
    let requiredRolls = 15
    let rollThresholdUpper = UIScreen.main.bounds.height / 3
    let rollThresholdLower = UIScreen.main.bounds.height * 1.75 / 3
    @State private var lastDirectionUp = false
    @State private var crossedThreshold = false
    @State private var countdown = 10
    @State private var timerRunning = false
    @State private var timerCancellable: AnyCancellable? = nil

    @State private var showFailMessage = false
    
    var body: some View {
        ZStack {
            // Main content
            ZStack {
                Image("dough")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: -10)
                thresholdIndicators

                Image("rollingpin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 250)
                    .offset(x: 10 + dragOffset.width, y: dragOffset.height)
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
                .onAppear {
                    startTimer()
                }
                .padding()
            }
            
            // Fail overlay
            if showFailMessage {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                Text("FAIL")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.red)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }

    func startTimer() {
        countdown = 10
        timerRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    timerExpired()
                }
            }
    }

    func stopTimer() {
        timerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func timerExpired() {
        stopTimer() // Stop the timer first
        if rollCount < requiredRolls {
            viewModel.pastryRollingFailedTimer = true // Set failure flag
            withAnimation {
                showFailMessage = true
            }
            // Hide fail message after 1.5 seconds and proceed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showFailMessage = false
                }
                // Use ViewModel's method if available, otherwise set directly
                // viewModel.finishRollingDough() // This method exists and sets stage and view var
                // For clarity with the task, setting directly:
                viewModel.currentStage = .prepPastry 
                viewModel.showDoughPrepView = true
            }
        } else {
            // Rolls completed by the time timer expired or before
            viewModel.pastryRollingFailedTimer = false // Ensure success flag state
            // Use ViewModel's method if available, otherwise set directly
            // viewModel.finishRollingDough()
            viewModel.currentStage = .prepPastry
            viewModel.showDoughPrepView = true
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
            PastryInstructionText(rollCount: rollCount, requiredRolls: requiredRolls, countdown: countdown)
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
                    stopTimer()
                    viewModel.pastryRollingFailedTimer = false // Explicitly set to false on success via button
                    // Use ViewModel's method if available, otherwise set directly
                    // viewModel.finishRollingDough()
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

        if rollCount >= requiredRolls {
            stopTimer()
        }
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
    let countdown: Int

    var body: some View {
        VStack {
            Text(rollCount < requiredRolls ? "Roll out the pastry dough. Rolls: \(rollCount)/\(requiredRolls)" : "Ready to bake!")
            Text("Time left: \(countdown)s")
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}
