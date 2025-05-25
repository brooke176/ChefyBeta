import SwiftUI
import Foundation

class SteakGameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var seasoning = SteakSeasoning()

    // Steak cooking variables
    @Published var cookingProgress = 0.0
    @Published var isCooking = false
    @Published var steakFlipped = true

    // Mushroom cooking variables
    @Published var mushroomCookingProgress = 0.0
    @Published var isMushroomsCooking = false
    @Published var mushroomStirred = false
    @Published var rotationDegrees = 0
    @Published var mushroomColor: Color = Color.brown
    @Published var mushroomsSpread = false
    @Published var isWellingtonCooking = false
    @Published var wellingtonCookingProgress = 0.0

    // Shared variables
    @Published var gameEnded = false
    @Published var gameMessage = ""
    @Published var showingLoadingOverlay = false
    @Published var showCookingView = false
    @Published var showMushroomView = false
    @Published var showDoughRollingView = false
    @Published var showDoughPrepView = false
    @Published var showOvenCookingView = false

    var timer: Timer?
    var seasoningGraphics: [SeasoningGraphic] = []
    var messagesViewController: MessagesViewController
    var onRequestCompactMode: (() -> Void)?
    private var conversationManager: ConversationManager?
    @Published var currentStage: GameStage? = nil

    let minSeasoningAmount: Double = 0.6
    let maxSeasoningAmount = 3.0
    let perfectSeasoningRange = 0.6...1.5
    let maxCookingProgress = 1.0
    let minCookingProgress = 0.0
    let minCookingProg = 0.0

    init(gameState: GameState, messagesViewController: MessagesViewController) {
        self.gameState = gameState
        self.messagesViewController = messagesViewController
    }

    func addSeasoningGraphics(type: SeasoningType) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let addAmount: Double = 0.1 * 5
        let seasoningColor = type == .salt ? Color.white : Color.black
        let side: SteakSide = !steakFlipped ? .back : .front
        switch (type, side) {
        case (.salt, .front):
            seasoning.frontSalt = min(seasoning.frontSalt + addAmount, maxSeasoningAmount)
        case (.salt, .back):
            seasoning.backSalt = min(seasoning.backSalt + addAmount, maxSeasoningAmount)
        case (.pepper, .front):
            seasoning.frontPepper = min(seasoning.frontPepper + addAmount, maxSeasoningAmount)
        case (.pepper, .back):
            seasoning.backPepper = min(seasoning.backPepper + addAmount, maxSeasoningAmount)
        }

        for _ in 1...5 {
            let newPosition = CGPoint(x: CGFloat.random(in: 180...280),
                                      y: CGFloat.random(in: 250...300))

            seasoningGraphics.append(SeasoningGraphic(position: newPosition, color: seasoningColor, type: type, side: side))
        }
    }

    func startCookingWellington() {
        currentStage = .cookWelly
        isWellingtonCooking = true
        showOvenCookingView = true
        wellingtonCookingProgress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.wellingtonCookingProgress += 0.1
            if self.wellingtonCookingProgress >= self.maxCookingProgress {
                self.endCookingWellington()
            }
        }
    }

    func startCookingMushrooms() {
        isMushroomsCooking = true
        mushroomCookingProgress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.mushroomCookingProgress += 0.1
            if self.mushroomCookingProgress >= self.maxCookingProgress {
                self.endCookingMushrooms()
            }
        }
    }

    func stirMushrooms() {
        mushroomStirred.toggle()
        rotationDegrees += 45
    }

    func endCookingMushrooms() {
        isMushroomsCooking = false
//        burnMushrooms()
        timer?.invalidate()
        resetMushroomCookingVariables()
    }
    
    func startCooking() {
        isCooking = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.cookingProgress += 0.1
            if self.cookingProgress >= self.maxCookingProgress {
                self.showMushroomView = true
            }
        }
    }

    func endCookingWellington() {
        isWellingtonCooking = false
        timer?.invalidate()
        showingLoadingOverlay = true

        let score = calculateScore()

        if gameState.currentPlayer == "player1" {
            gameState.player1Score = score
            gameState.player1Played = true
            gameState.currentPlayer = "player2"
        } else if gameState.currentPlayer == "player2" {
            gameState.player2Score = score
            gameState.player2Played = true
            gameState.currentPlayer = "player1"
        }

        messagesViewController.gameState = gameState
        messagesViewController.updateAndSendGameState {
            DispatchQueue.main.async {
                self.checkGameEnd()
                self.resetGame()
                self.currentStage = .outcome
                self.onRequestCompactMode?()
            }
        }
    }

    func finishRollingDough() {
        showDoughPrepView = true
    }

    func deepenMushroomColor() {
        mushroomColor = mushroomColor.opacity(0.85)
    }

    func burnMushrooms() {
        mushroomColor = .black
        print("Burnt!")
    }

    func resetMushroomCookingVariables() {
        mushroomCookingProgress = 0
        isMushroomsCooking = false
        mushroomStirred = false
    }

    func serveSteak() {
        currentStage = .sauteMushrooms
        self.showMushroomView = true
    }

    private func calculateScore() -> Int {
        let isFrontSeasoned = seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount
        let isBackSeasoned = seasoning.backSalt >= minSeasoningAmount && seasoning.backPepper >= minSeasoningAmount
        // TODO: fix progress bar
        let cookingCorrectlyDone = wellingtonCookingProgress >= 0.6 && wellingtonCookingProgress <= 1
        NSLog("cookingProgress: \(wellingtonCookingProgress)")

        let perfectScore = isFrontSeasoned && isBackSeasoned && cookingCorrectlyDone
        let okScore = isFrontSeasoned && isBackSeasoned
        let score = perfectScore ? 3 : okScore ? 2 : 1
        NSLog("score: \(score)")

        return score
    }

     func resetGame() {
        cookingProgress = 0
        isCooking = false
        steakFlipped = false
        gameEnded = false
        seasoningGraphics = []
    }

    func checkGameEnd() {
        if gameState.player1Played && gameState.player2Played {
            gameEnded = true
            gameMessage = determineWinner()
        }
    }

     func determineWinner() -> String {
        if gameState.player1Score > gameState.player2Score {
            return "Player 1 wins with a score of \(gameState.player1Score)!"
        } else if gameState.player2Score > gameState.player1Score {
            return "Player 2 wins with a score of \(gameState.player2Score)!"
        } else {
            return "It's a tie!"
        }
    }
}
