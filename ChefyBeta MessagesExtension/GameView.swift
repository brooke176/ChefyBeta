import SwiftUI

struct GameView: View {
    @State private var seasoningAmount = 0.0
    @State private var cookingProgress = 0.0
    @State private var isCooking = false
    @State private var steakFlipped = false
    
    let maxSeasoningAmount = 1.0
    let maxCookingProgress = 1.0
    
    var body: some View {
        VStack {
            Text("Season the steak")
                .padding()
            
            // Steak image
            Image("steak") // Add your steak image
                .onTapGesture {
                    self.flipSteak()
                }
            
            // Seasoning shaker
            Image("seasoning") // Add your seasoning shaker image
                .onTapGesture {
                    self.seasonSteak()
                }
            
            // Cooking progress bar
            ProgressView(value: cookingProgress, total: maxCookingProgress)
                .padding()
            
            // Start cooking button
            Button("Start Cooking") {
                self.startCooking()
            }
            .disabled(isCooking)
        }
        .alert(isPresented: .constant(seasoningAmount > maxSeasoningAmount || cookingProgress > maxCookingProgress)) {
            Alert(
                title: Text("Game Over"),
                message: Text("You've \(seasoningAmount > maxSeasoningAmount ? "over-seasoned" : "burnt") the steak!"),
                dismissButton: .default(Text("Try Again"), action: resetGame)
            )
        }
    }
    
    func seasonSteak() {
        if !isCooking {
            seasoningAmount += 0.1
            if seasoningAmount > maxSeasoningAmount {
                // Lose condition for too much seasoning
                isCooking = false // Stop the game
            }
        }
    }
    
    func flipSteak() {
        if isCooking && !steakFlipped {
            steakFlipped = true
            cookingProgress = 0 // Reset progress
        }
    }
    
    func startCooking() {
        isCooking = true
        steakFlipped = false
        cookingProgress = 0
        
        // Timer to simulate cooking progress
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.cookingProgress += 0.1
            if self.cookingProgress > self.maxCookingProgress {
                timer.invalidate()
                isCooking = false // Stop the game
            }
        }
    }
    
    func resetGame() {
        seasoningAmount = 0
        cookingProgress = 0
        isCooking = false
        steakFlipped = false
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
