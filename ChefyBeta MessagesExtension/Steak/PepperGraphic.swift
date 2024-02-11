import Foundation
import SwiftUI

struct SeasoningGraphic: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let type: SeasoningType
    let side: SteakSide
}

enum SteakSide {
    case front, back
}
