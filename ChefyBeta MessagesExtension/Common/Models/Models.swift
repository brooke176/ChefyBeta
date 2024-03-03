import Foundation
import SwiftUI

struct GameState: Equatable {
    var player1Score: Int = 0
    var player2Score: Int = 0
    var player1Played: Bool = false
    var player2Played: Bool = false
    var currentPlayer: String = "player1" // or "player2"
    var gameType: String?
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
}

enum SeasoningType {
    case salt, pepper
}

struct SeasoningGraphic: Identifiable {
    var id = UUID()
    var position: CGPoint
    var color: Color
    var type: SeasoningType
    var side: SteakSide
}

enum SteakSide {
    case front, back
}

enum GameType: String {
    case BeefWelly = "Beef Welly"
    case pancakes = "pancakes"
}

enum EggState {
    case whole, cracked, exploded
}

struct Egg {
    var state: EggState = .whole
    var position: CGPoint?
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
        }
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

enum GameStage: String, CaseIterable, Identifiable {
    case crackEggs
    case measureIngredients
    case cookPancakes
    case outcome

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
