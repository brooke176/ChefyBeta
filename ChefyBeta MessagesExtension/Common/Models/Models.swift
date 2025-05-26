import Foundation
import SwiftUI

struct GameState {
    var gameType: String?
    var player1Score: Int = 0
    var player2Score: Int = 0
    var player1Played: Bool = false
    var player2Played: Bool = false
    var currentPlayer: String = "player1"
    var player1Id: String?

    var gameHasStarted: Bool {
        return player1Played
    }
}

struct ImageItem: Identifiable {
    let id: Int
    let imageName: String
    let label: String
}

var imageItems: [ImageItem] = [
    ImageItem(id: 1, imageName: "beef_wellington", label: "Beef Welly"),
    ImageItem(id: 2, imageName: "pancakes", label: "Pancakes"),
    ImageItem(id: 3, imageName: "carbonara", label: "Carbonara"),
    ImageItem(id: 4, imageName: "california_roll", label: "Sushi"),
    ImageItem(id: 5, imageName: "nachos", label: "Nachos"),
    ImageItem(id: 6, imageName: "potato", label: "Potato"),
    ImageItem(id: 7, imageName: "cake", label: "Cake"),
    ImageItem(id: 8, imageName: "burrito", label: "Burrito")
]

struct SteakSeasoning {
    var frontSalt: Double = 0
    var backSalt: Double = 0
    var frontPepper: Double = 0
    var backPepper: Double = 0
    // seasoningCorrectness is in the ViewModel, not here.
}

// SteakSide enum is defined below - ensure it's the single source of truth.
// SeasoningType enum is defined below.

struct SeasoningGraphic: Identifiable {
    var id = UUID()
    var position: CGPoint
    var color: Color
    var type: SeasoningType
    var side: SteakSide // Uses SteakSide enum defined in this file
}

enum SeasoningType { // Ensure this is used or remove if only ViewModel used it
    case salt, pepper
}

enum SteakSide { // Single source of truth for SteakSide
    case front, back
}

enum GameScoreMetric { // Moved from ViewModel
    case poor, okay, good, perfect
}

enum GameType: String {
    case BeefWelly = "welly"
    case pancakes = "pancakes"
}

enum EggState {
    case whole, cracked, exploded, gone
}

struct Egg: Identifiable {
    var id = UUID()
    var state: EggState = .whole
    var position: CGPoint? = nil
    var isSelected: Bool = false
    var dragSpeed: CGFloat = 0

    var imageName: String {
        switch state {
        case .whole:
            return "egg"
        case .cracked:
            return "cracked_eggy"
        case .exploded:
            return "exploded_egg"
        case .gone:
            return ""
        }
    }

    init(id: UUID = UUID(), state: EggState = .whole, position: CGPoint? = nil, isSelected: Bool = false) {
        self.id = id
        self.state = state
        self.position = position
        self.isSelected = isSelected
    }
}

struct Pancake: Identifiable {
    let id = UUID()
    var position: CGPoint
    var state: PancakeState = .batter
    var cookingProgress: Double = 0.0
    var hasBeenFlipped: Bool = false
    var cookingTime: TimeInterval = 0
    var type: PancakeType = .plain
}

enum PancakeState {
    case batter, readyToFlip, flipped, done, burned
}

enum PancakeType {
    case plain, blueberry, chocolateChip
}

enum PancakeGameStage: String, CaseIterable, Identifiable {
    case crackEggs
    case measureIngredients
    case cookPancakes
    case outcome

    var id: String { self.rawValue }
}

enum GameStage: String, CaseIterable, Identifiable { // Updated cases
    case seasonSteak // Initial stage
    case searSteak // Player sears steak (was cookSteak)
    case sauteMushrooms // Player sautés mushrooms
    case rollDough // Player rolls dough (was rollPastry)
    case prepPastry // Player preps pastry (e.g., spread mushrooms)
    case cookWelly // Player cooks the wellington
    case outcome // Game outcome/score shown

    var id: String { self.rawValue }
}

    struct GameButtonStyle: ButtonStyle {
        var backgroundColor: Color
        var isDisabled: Bool = false

        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(isDisabled ? backgroundColor.opacity(0.5) : backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeInOut, value: configuration.isPressed)
        }
    }
