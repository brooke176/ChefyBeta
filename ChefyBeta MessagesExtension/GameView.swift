import SwiftUI

struct GameView: View {
    @State private var seasoningAmounts = [0.0, 0.0]
    @State private var cookingProgress = 0.0
    @State private var isCooking = false
    @State private var steakFlipped = false
    @State private var gameEnded = false
    @State private var gameMessage = ""
    @State private var showFireEffect = false
    @State private var timer: Timer?
    @State private var pepperGraphics: [PepperGraphic] = []
    @State private var score = 1
    @State private var showingCompletedDishView = false

    let minSeasoningAmount: Double = 0.6
    let maxSeasoningAmount = 3.0
    let perfectSeasoningRange = 0.6...1.5
    let maxCookingProgress = 1.0

    var body: some View {
        VStack {
            Spacer()
            Text(instructionText)
                .padding()
            Spacer()
            gameViewContent
            Spacer()
            actionButtons
            Spacer()
        }
        .sheet(isPresented: $showingCompletedDishView) {
            CompletedDishView(score: score)
        }
    }

    private var gameViewContent: some View {
        ZStack(alignment: .center) {
            Image("stove2")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 317)

            Image("pan")
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 190)
                .offset(y: 20)

            Image("steak")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .rotation3DEffect(.degrees(steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: steakFlipped)

            ForEach(pepperGraphics) { graphic in
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
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
                self.flipSteak()
            }
        }
    }

    private var actionButtons: some View {
        Group {
            if !isCooking {
                Button("Start Cooking") {
                    self.startCooking()
                }
                .disabled(seasoningAmounts[0] < minSeasoningAmount || (steakFlipped && seasoningAmounts[1] < minSeasoningAmount))
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button("Serve Steak") {
                    self.serveSteak()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Image("salt")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .padding(.top, 30)
                .onTapGesture {
                    self.addPepperGraphic()
                }

            ProgressBar(progress: cookingProgress)
                .frame(height: 20)
                .padding()
        }
    }

    private var instructionText: String {
        if gameEnded {
            return gameMessage
        } else if !isCooking {
            if !steakFlipped && seasoningAmounts[0] < minSeasoningAmount {
                return "Season the first side of the steak"
            } else if steakFlipped && seasoningAmounts[1] < minSeasoningAmount {
                return "Season the flipped side of the steak"
            } else {
                return "Start cooking the steak"
            }
        } else if cookingProgress < 0.6 {
            return "Keep cooking..."
        } else {
            return "Serve the steak"
        }
    }

    private func addPepperGraphic() {
        let addAmount = 0.1 * 3 // Example seasoning added per action
        let sideIndex = steakFlipped ? 1 : 0
        if !isCooking && seasoningAmounts[sideIndex] < maxSeasoningAmount {
            seasoningAmounts[sideIndex] += addAmount
            for _ in 1...3 {
                let newPosition = CGPoint(x: CGFloat.random(in: 175...200) - 35.0, y: CGFloat.random(in: 175...200) - 35.0)
                pepperGraphics.append(PepperGraphic(position: newPosition))
            }
        }
    }

    private func flipSteak() {
        steakFlipped.toggle()
        pepperGraphics = [] // Clear pepper graphics for the second side
    }

    private func startCooking() {
        isCooking = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.cookingProgress += 0.1
            if self.cookingProgress >= self.maxCookingProgress {
                self.stopCooking()
            }
        }
    }

    private func serveSteak() {
        stopCooking()
        if cookingProgress > 0.8 {
            gameMessage = "The steak is overcooked!"
            showFireEffect = true
        } else if cookingProgress > 0.6 {
            gameMessage = "Congratulations! You've cooked the perfect steak!"
        } else {
            gameMessage = "The steak is undercooked! DISGUSTING!!!!!"
        }
        gameEnded = true
        showingCompletedDishView = true
        resetGame()
    }

    private func stopCooking() {
        isCooking = false
        timer?.invalidate()
        timer = nil
    }

    private func resetGame() {
        cookingProgress = 0
        isCooking = false
        steakFlipped = false
        gameEnded = false
        showFireEffect = false
        pepperGraphics = []
        seasoningAmounts = [0.0, 0.0]
    }

    private func calculateScore() {
        let firstSideCorrectlySeasoned = perfectSeasoningRange.contains(seasoningAmounts[0])
        let secondSideCorrectlySeasoned = perfectSeasoningRange.contains(seasoningAmounts[1])
        let cookingCorrectlyDone = cookingProgress >= 0.6 && cookingProgress <= 0.8
        let perfectScore = firstSideCorrectlySeasoned && secondSideCorrectlySeasoned && cookingCorrectlyDone && steakFlipped
        let okScore = steakFlipped && (firstSideCorrectlySeasoned || secondSideCorrectlySeasoned) && cookingCorrectlyDone
        score = perfectScore ? 3 : okScore ? 2 : 1
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
