import SwiftUI

struct PrepPastryView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    @State private var paths: [Path] = []
    @State private var totalDrawnArea: CGFloat = 0

    @State private var showProsciutto = false
    @State private var showSteak = false
    var messagesViewController: MessagesViewController

    let brushWidth: CGFloat = 15
    let interactiveAreaRect: CGRect

    init(viewModel: SteakGameViewModel, messagesViewController: MessagesViewController) {
        self.viewModel = viewModel
        self.messagesViewController = messagesViewController
        self.interactiveAreaRect = CGRect(
            x: UIScreen.main.bounds.width / 2.6,
            y: UIScreen.main.bounds.height / 3,
            width: 300,
            height: 200
        )
    }

    var body: some View {
            ZStack {
                Image("dough")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if viewModel.mushroomsSpread && !showProsciutto {
                            showProsciutto = true
                        } else if showProsciutto && !showSteak {
                            showSteak = true
                        }
                    }

                if showProsciutto {
                    Image("prosciutto")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                }

                if showSteak {
                    Image("steakie")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                }

                if !viewModel.mushroomsSpread {
                    Canvas { context, _ in
                        for path in paths {
                            var strokeStyle = StrokeStyle()
                            strokeStyle.lineWidth = brushWidth
                            let brownColor = Color.brown
                            context.stroke(path, with: .color(brownColor), style: strokeStyle)
                        }
                    }
                    .background(Color.clear)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                updatePathsWith(value: value)
                            })
                        )}
                Spacer()
                VStack {
                    // Updated instruction text
                    Text(viewModel.mushroomsSpread ? "Place prosciutto and steak" : "Spread mushrooms: \(Int(viewModel.mushroomSpreadCoveragePercent * 100))%")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(Color.black)
                        .font(.headline)
                        .lineLimit(1) // Ensure it fits on one line if possible
                        .minimumScaleFactor(0.5) // Allow font to shrink
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 40) // Ensure a minimum height for the text box
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.pink.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.vertical, 5)

                    Spacer()

                    // This button logic seems fine and is part of the main struct, not PastryButtons.
                    if viewModel.mushroomsSpread {
                        Button("Start cooking beef wellington") {
                             // viewModel.finishPastryPrep() // This was a new method I thought of, but task implies direct call.
                             // The finishPastryPrep in ViewModel calls startCookingWellington.
                             // So, directly calling startCookingWellington is also fine as per original code.
                            viewModel.startCookingWellington()
                        }
                        .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                    }

                    // Updated ProgressView
                    ProgressView(value: viewModel.mushroomSpreadCoveragePercent, total: 1.0)
                        .frame(height: 20)
                        .padding()
                }
                Spacer()
                }
        .onAppear {
            // Reset coverage percent when view appears for a new session of spreading
            viewModel.mushroomSpreadCoveragePercent = 0.0
            viewModel.mushroomsSpread = false // Also reset the boolean flag
        }
    }

    private func updatePathsWith(value: DragGesture.Value) {
        let newPoint = value.location
        if interactiveAreaRect.contains(newPoint) {
            // Append point to path for drawing
            if paths.isEmpty {
                var newPath = Path()
                newPath.move(to: newPoint)
                paths.append(newPath)
            } else {
                paths[paths.count - 1].addLine(to: newPoint)
            }

            // Increment drawn area - this is an approximation.
            // A more accurate way might involve calculating the actual area of the path,
            // but for a game, an approximation based on drag distance/brush size is often fine.
            // Here, we assume each segment of drag contributes a fixed amount.
            // The existing `totalDrawnArea += 10` is a simple heuristic.
            totalDrawnArea += brushWidth // Add area equivalent to brush width for each new point segment
            
            // Calculate coverage and update ViewModel
            let doughArea = interactiveAreaRect.width * interactiveAreaRect.height
            let currentCoverage = totalDrawnArea / doughArea
            viewModel.mushroomSpreadCoveragePercent = min(currentCoverage, 1.0) // Cap at 100%

            // Update the boolean flag if a certain threshold is met (e.g., 50% coverage)
            // This controls when the UI switches to "Place prosciutto and steak"
            // The original 0.01 (1%) threshold might be too low for this flag.
            // Let's use a slightly higher threshold for `mushroomsSpread` to be true, e.g., 50%.
            // The scoring will use the actual `mushroomSpreadCoveragePercent`.
            if viewModel.mushroomSpreadCoveragePercent >= 0.5 { // Example: 50% to consider it "spread enough" for next step
                if !viewModel.mushroomsSpread { // Only set to true once to avoid repeated UI refreshes if not needed
                    viewModel.mushroomsSpread = true
                }
            }
        }
    }

    // updateMushroomsSpread() is now integrated into updatePathsWith.
    // If it were separate, it would just use viewModel.mushroomSpreadCoveragePercent.

    // PastryButtons struct seems to be unused as the button is directly in the main VStack.
    // I will remove it if it's not referenced elsewhere, or ensure its logic is merged/correct.
    // For now, assuming it's not used as the relevant button is in PrepPastryView's body.
    // struct PastryButtons: View {
    // ...
    // }
}

// Note: The PastryButtons struct was present in the original file but appears to be unused,
// as the "Start cooking beef wellington" button is defined directly within PrepPastryView's body.
// If PastryButtons was intended to be used, its content should be reviewed and integrated.
// For this task, I've focused on modifying the existing button and ProgressView logic.
        @ObservedObject var viewModel: SteakGameViewModel

        var body: some View {
            VStack {
                Button("Start cooking beef wellington") {
                    viewModel.currentStage = .cookWelly
                    viewModel.showOvenCookingView = true
                    viewModel.startCookingWellington()
                }
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
            }
        }
    }
}
