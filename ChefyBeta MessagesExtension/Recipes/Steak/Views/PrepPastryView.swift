import SwiftUI

struct PrepPastryView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    @State private var paths: [Path] = []
    @State private var totalDrawnArea: CGFloat = 0

    @State private var showProsciutto = false
    @State private var showSteak = false
    var messagesViewController: MessagesViewController

    let doughWidth: CGFloat = 300 // Width of the dough area, adjust as needed
    let doughHeight: CGFloat = 200 // Height of the dough area, adjust as needed
    let brushWidth: CGFloat = 10 // Width of the "brush" used for spreading
    let interactiveAreaRect: CGRect

    init(viewModel: SteakGameViewModel, messagesViewController: MessagesViewController) {
        self.viewModel = viewModel
        self.messagesViewController = messagesViewController
        self.interactiveAreaRect = CGRect(
            x: UIScreen.main.bounds.width / 1.6,
            y: UIScreen.main.bounds.height / 2.5,
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
                    Text(viewModel.mushroomsSpread ? "Place prosciutto and steak" : "Keep spreading the mushrooms")
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
                                        gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.pink.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.vertical, 5)

                    Spacer()

                    if viewModel.mushroomsSpread {
                        Button("Start cooking beef wellington") {
                            viewModel.startCookingWellington()
                        }
                        .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                    }

                    ProgressView(value: viewModel.mushroomsSpread ? 1.0 : 0.0, total: 1.0)
                        .frame(height: 20)
                        .padding()
                }
                Spacer()
                }
        .onAppear {
            viewModel.mushroomsSpread = false
        }
    }

    private func updatePathsWith(value: DragGesture.Value) {
        let newPoint = value.location
        if interactiveAreaRect.contains(newPoint) {
            if let lastPath = paths.popLast() {
                var newPath = lastPath
                newPath.addLine(to: newPoint)
                paths.append(newPath)
            } else {
                var newPath = Path()
                newPath.move(to: newPoint)
                newPath.addLine(to: newPoint)
                paths.append(newPath)
            }

            totalDrawnArea += 10
            updateMushroomsSpread()
        }
    }

    func updateMushroomsSpread() {
        let doughArea = interactiveAreaRect.width * interactiveAreaRect.height
        let coverage = totalDrawnArea / doughArea

        if coverage >= 0.01 {
            viewModel.mushroomsSpread = true
        }
    }

    struct PastryButtons: View {
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
