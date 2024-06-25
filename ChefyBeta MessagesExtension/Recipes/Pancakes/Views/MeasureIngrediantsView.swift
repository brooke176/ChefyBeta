import SwiftUI

struct MeasuringIngredientsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    @State private var currentAmount: Double = 0.0
    let targetAmount: Double = 1.0
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            Image(viewModel.backgroundImageName())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .offset(x: -25, y: 0)

            VStack {
                Text("Let's Measure Ingredients!")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)

                Text("Drag the flour, sugar, and milk ingredients to the bowl.")
                    .font(.subheadline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                HStack {
                    DraggableIngredientView(ingredientName: "milk", viewModel: viewModel, initialPosition: CGPoint(x: 63, y: 85))
                    DraggableIngredientView(ingredientName: "sugar", viewModel: viewModel, initialPosition: CGPoint(x: 238, y: 85))
                    DraggableIngredientView(ingredientName: "flour", viewModel: viewModel, initialPosition: CGPoint(x: 34, y: 85))
                }

                VStack {
                    Button("Start cooking!") {
                        viewModel.currentStage = .cookPancakes
                    }
                    .buttonStyle(GameButtonStyle(backgroundColor: .blue))
                }
            }
            .padding()
        }
    }
}

struct DraggableIngredientView: View {
    @State private var position: CGPoint
    var ingredientName: String
    @ObservedObject var viewModel: PancakeGameViewModel
    let initialPosition: CGPoint

    init(ingredientName: String, viewModel: PancakeGameViewModel, initialPosition: CGPoint) {
        self.ingredientName = ingredientName
        self.viewModel = viewModel
        self.initialPosition = initialPosition
        self._position = State(initialValue: initialPosition)
    }

    var body: some View {
        Image(ingredientName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.position = value.location
                    }
                    .onEnded { _ in
//                        if self.viewModel.isDropLocationCorrect(value.location, for: ingredientName) {
                        // TODO: fix isDropLocationCorrect function
                        self.viewModel.ingredientsDropped.insert(self.ingredientName)
                            self.position = self.initialPosition
//                        } else {
//                            self.position = self.initialPosition
//                        }
                    }
            )
    }
}
