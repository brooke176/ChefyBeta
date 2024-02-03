import Foundation

enum NavigationTarget: Identifiable {
    case completedDish(score: Int)

    var id: Int {
        switch self {
        case .completedDish(let score):
            return score // Use the score or another unique identifier here
        }
    }
}
