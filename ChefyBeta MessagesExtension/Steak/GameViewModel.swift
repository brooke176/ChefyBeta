import SwiftUI
import Foundation

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var seasoning = SteakSeasoning()
    @Published var cookingProgress = 0.0
    @Published var isCooking = false
    @Published var steakFlipped = false
    @Published var gameEnded = false
    @Published var gameMessage = ""
    @Published var showFireEffect = false
    var timer: Timer?
    var seasoningGraphics: [SeasoningGraphic] = []

    init(gameState: GameState) {
        self.gameState = gameState
    }

    // Place your game logic functions here (startCooking, serveSteak, calculateScore, etc.)
}
