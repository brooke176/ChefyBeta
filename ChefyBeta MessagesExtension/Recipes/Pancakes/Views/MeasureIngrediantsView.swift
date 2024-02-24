import SwiftUI

struct MeasuringIngredientsView: View {
    @ObservedObject var viewModel: PancakeGameViewModel
    @State private var showAlert = false // State for showing the alert

    var body: some View {
        VStack(alignment: .leading) {
            Text("Let's Measure Ingredients!")
                .font(.title)
                .padding(.bottom)

            Text("Drag each slider to measure the correct amount of ingredients needed for your pancakes.")
                .padding(.bottom)

            IngredientSliderView(ingredient: "Milk", amount: $viewModel.milkAmount, range: 0...2)
            IngredientSliderView(ingredient: "Flour", amount: $viewModel.flourAmount, range: 0...3)
            IngredientSliderView(ingredient: "Sugar", amount: $viewModel.sugarAmount, range: 0...1)

            Button("Check Ingredients") {
                showAlert = true
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

// Custom Slider View
struct IngredientSliderView: View {
    var ingredient: String
    @Binding var amount: Double
    var range: ClosedRange<Double>

    var body: some View {
        VStack {
            HStack {
                Text("\(ingredient):")
                Spacer()
                Text("\(amount, specifier: "%.1f") cups")
            }
            Slider(value: $amount, in: range, step: 0.1)
                .accentColor(.green) // Customize the slider color
        }
        .padding(.vertical)
    }
}
