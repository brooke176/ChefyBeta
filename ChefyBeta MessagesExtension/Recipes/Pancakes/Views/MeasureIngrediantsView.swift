import SwiftUI

struct MeasuringIngredientsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    @State private var showAlert = false
    @State private var currentAmount: Double = 0.0
    let targetAmount: Double = 1.0
    
    var body: some View {
        ZStack {
            Image("eggbackground")
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
                    DraggableIngredientView(ingredientName: "milk", viewModel: viewModel, position: CGPoint(x: 55, y: 49))
                    DraggableIngredientView(ingredientName: "sugar", viewModel: viewModel, position: CGPoint(x: 224, y: 49))
                    DraggableIngredientView(ingredientName: "flour", viewModel: viewModel, position: CGPoint(x: 26, y: 49))
                }

                VStack {
                    Button("Check Ingredients") {
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Ingredients Check"),
                        message: Text(viewModel.checkIngredientsMeasuredCorrectly() ? "Correct Amounts! 🎉" : "Incorrect, try again! 😞"),
                        dismissButton: .default(Text("OK"))
                    )
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

    init(ingredientName: String, viewModel: PancakeGameViewModel, position: CGPoint) {
        self.ingredientName = ingredientName
        self.viewModel = viewModel
        self._position = State(initialValue: position)
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
                        // Handle dropping logic here
                    }
            )
            .padding()
    }
}


