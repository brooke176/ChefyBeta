import SwiftUI

struct GameView: View {
    @State private var seasoningAmount = 0.0
    @State private var cookingProgress = 0.0
    @State private var isCooking = false
    @State private var burgerFlipped = false
    
    let maxSeasoningAmount = 1.0
    let perfectSeasoningRange = 0.5...0.8
    let maxCookingProgress = 1.0
    let cookingFlipPoint = 0.5
    
    var body: some View {
        VStack {
            Text("Season the burger")
                .padding()
            
            Image("patty") // Placeholder for your burger image
                .resizable()
                .scaledToFit()
                .shadow(radius: 1)
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(burgerFlipped ? 180 : 0)) // Flip animation
                .onTapGesture {
                    if isCooking {
                        self.flipBurger()
                    }
                }
            
            Image("pepper") // Placeholder for your seasoning image
                .resizable()
                .scaledToFit()
                .shadow(radius: 1)
                .frame(width: 90, height: 90)
                .onTapGesture {
                    if !isCooking {
                        self.seasonBurger()
                    }
                }
            
            ProgressView(value: cookingProgress, total: maxCookingProgress)
                .padding()
            
            Button("Start Cooking") {
                self.startCooking()
            }
            .disabled(isCooking || seasoningAmount < perfectSeasoningRange.lowerBound)
        }
        .alert(isPresented: .constant(checkGameOver())) {
            if cookingProgress >= maxCookingProgress && seasoningAmount >= perfectSeasoningRange.lowerBound && seasoningAmount <= perfectSeasoningRange.upperBound && burgerFlipped {
                return Alert(
                    title: Text("Congratulations!"),
                    message: Text("You've cooked the perfect burger!"),
                    dismissButton: .default(Text("Play Again"), action: resetGame)
                )
            } else {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Try to season correctly and flip the burger at the right time."),
                    dismissButton: .default(Text("Try Again"), action: resetGame)
                )
            }
        }
    }
    
    func seasonBurger() {
        seasoningAmount += 0.1
    }
    
    func flipBurger() {
        burgerFlipped = true
    }
    
    func startCooking() {
        isCooking = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.cookingProgress += 0.1
            if self.cookingProgress >= self.maxCookingProgress {
                timer.invalidate()
                self.isCooking = false
            }
        }
    }
    
    func checkGameOver() -> Bool {
        if cookingProgress >= maxCookingProgress {
            if seasoningAmount >= perfectSeasoningRange.lowerBound && seasoningAmount <= perfectSeasoningRange.upperBound && burgerFlipped {
                // Win condition
                return true
            }
            // Lose condition
            return true
        }
        return false
    }
    
    func resetGame() {
        seasoningAmount = 0
        cookingProgress = 0
        isCooking = false
        burgerFlipped = false
    }
}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}


//#Preview {
//    GameView()
//}
