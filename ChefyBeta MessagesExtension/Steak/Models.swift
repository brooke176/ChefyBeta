import Foundation
import SwiftUI

struct GameState: Equatable {
    var player1Score: Int = 0
    var player2Score: Int = 0
    var player1Played: Bool = false
    var player2Played: Bool = false
    var currentPlayer: String?
}

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
