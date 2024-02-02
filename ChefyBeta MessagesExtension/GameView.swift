import SwiftUI

struct GameView: View {
    @State private var seasoningAmount = 0.0
    @State private var minSeasoningAmount: Double = 0.3 // Example minimum value, adjust as needed
    @State private var cookingProgress = 0.0
    @State private var isCooking = false
    @State private var burgerFlipped = false
    @State private var gameEnded = false
    @State private var gameMessage = ""
    @State private var fireEffect = false
    @State private var showFireEffect = false
    @State private var fireEffectSize: CGFloat = 150
    @State private var timer: Timer?
    @State private var pepperGraphics: [PepperGraphic] = []

    let maxSeasoningAmount = 3.0
    let perfectSeasoningRange = 0.6...1.5
    let maxCookingProgress = 1.0

    var body: some View {
        VStack {
            Spacer()
            if seasoningAmount < minSeasoningAmount {
                Text("Season the burger")
                    .padding()
            } else if isCooking && !burgerFlipped {
                Text("Flip the burger")
                    .padding()
            } else if isCooking && burgerFlipped && cookingProgress > 0.6 {
            Text("Serve the burger")
                .padding()
            } else if isCooking && burgerFlipped && cookingProgress < 0.6 {
            Text("Keep cooking...")
                .padding()
        }
        else if !isCooking {
            Text("Cook the burger")
                .padding()
        }
            ZStack(alignment: .center) {
                Image("patty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(burgerFlipped ? 180 : 0))
                
                ForEach(pepperGraphics) { graphic in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                        .position(graphic.position)
                }
                if showFireEffect {
                    Image("fire")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
            }
            .frame(width: 150, height: 150)
            .onTapGesture {
                if isCooking {
                    self.flipBurger()
                }
            }
            
            Image("pepper")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .onTapGesture {
                    self.addPepperGraphic()
                }
            
            ProgressBar(progress: cookingProgress)
                .frame(height: 20)
                .padding()
            
            if isCooking {
                Button("Serve Burger") {
                    self.serveBurger()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button("Start Cooking") {
                    self.startCooking()
                }
                .disabled(pepperGraphics.isEmpty) // Disable button until pepper is pressed
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            Spacer()
        }
        .alert(isPresented: $gameEnded) {
            Alert(title: Text("Game Over"), message: Text(gameMessage), dismissButton: .default(Text("Try Again"), action: resetGame))
        }
    }
    
    func addPepperGraphic() {
        if !isCooking && seasoningAmount < maxSeasoningAmount {
            let addAmount = min(0.1 * 3, maxSeasoningAmount - seasoningAmount)
            seasoningAmount += addAmount
            
            for _ in 1...3 {
                let newPosition = CGPoint(x: CGFloat.random(in: 20...130), y: CGFloat.random(in: 20...130))
                pepperGraphics.append(PepperGraphic(position: newPosition))
            }
        } else {
            self.gameMessage = "WAYYYYYY too salty girl"
            self.gameEnded = true
        }
    }
    
    func flipBurger() {
        burgerFlipped.toggle()
    }
    
    func startCooking() {
        isCooking = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.cookingProgress += 0.1
            if self.cookingProgress >= self.maxCookingProgress {
                self.stopCooking()
                if !self.burgerFlipped {
                    self.gameMessage = "You forgot to flip the burger! It's burned on one side!"
                } else {
                    self.gameMessage = "FLOP!!! You burned the burger!"
                    self.showFireEffect = true
                }
                self.gameEnded = true
                self.showFireEffect = false
                self.fireEffectSize = 150
            }
        }
    }
    
    func serveBurger() {
        stopCooking()
        if cookingProgress > 0.8 {
            showFireEffect = true
                self.gameMessage = "FLOP!!! You burned the burger!"
                self.gameEnded = true
                self.showFireEffect = false
                self.resetFireEffect()
                } else if cookingProgress > 0.6 {
                    gameMessage = "Congratulations! You've cooked the perfect burger!"
                    gameEnded = true
                } else {
                    gameMessage = "The burger is undercooked! DISGUSTING!!!!!"
                    gameEnded = true
                }
            }
    
    func stopCooking() {
        isCooking = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetFireEffect() {
        showFireEffect = false
        fireEffectSize = 150
    }
    
    func resetGame() {
        seasoningAmount = 0
        cookingProgress = 0
        isCooking = false
        burgerFlipped = false
        gameEnded = false
        gameMessage = ""
        fireEffect = false
        showFireEffect = false
        fireEffectSize = 150
        pepperGraphics = []
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
