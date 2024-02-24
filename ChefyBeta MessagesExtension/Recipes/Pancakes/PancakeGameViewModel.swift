import Foundation
import SwiftUI

enum pancakeState {
    case idle
    case cooking
    case finished
}

enum EggState {
    case whole, cracked, exploded
}

struct Egg {
    var state: EggState = .whole
    var position: CGPoint? // Updated to be optional
    var isSelected: Bool = false

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

class PancakeGameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var pancakeState: pancakeState
    @Published var eggTimer: Double = 0
    @Published var showOutcomeView: Bool = false
    @Published var eggsCracked: Int = 0
    @Published var currentEggState: EggState = .whole
    @Published var showMixingView = false
    @Published var eggs: [Egg] = []
    var pickedEggIndex: Int? // Track the index of the picked-up egg

    // Measuring Ingredients for Step 2
    @Published var milkAmount: Double = 0
    @Published var flourAmount: Double = 0
    @Published var sugarAmount: Double = 0

    let targetMilkAmount: Double = 1.0
    let targetFlourAmount: Double = 2.0
    let targetSugarAmount: Double = 0.5

    let eggsToCrack: Int = 5
    var dragStartTime: Date?
    var timer: Timer?

    var allEggsCracked: Bool {
        eggs.allSatisfy { $0.state == .cracked }
    }

    init(gameState: GameState) {
        self.gameState = gameState
        self.pancakeState = .idle
        resetEggs() // Ensure this is called to initialize eggs to .whole
    }

    func startCooking() {
        pancakeState = .cooking
        resetEggs()
        showOutcomeView = false
        eggTimer = 30.0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.eggTimer -= 1
            if self.eggTimer <= 0 {
                self.finishCooking()
            }
        }
    }

    func finishCooking() {
        timer?.invalidate()
        pancakeState = .finished
        showOutcomeView = true
    }

    func resetEggs() {
         eggs = Array(repeating: Egg(), count: eggsToCrack) // Initialize eggs with default states and positions
     }

    func pickUpEgg(at index: Int) {
        guard eggs.indices.contains(index), eggs[index].state == .whole else { return }
        pickedEggIndex = index // Mark this egg as being picked up
    }

    func crackPickedEgg(at position: CGPoint) {
        eggsCracked += 1
        guard let index = pickedEggIndex else { return }
        eggs[index].state = .cracked
        eggs[index].position = position // Update to use the exact tap location

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.eggs[index].state = .exploded
            }
        }
    }

    func checkIngredientsMeasuredCorrectly() -> Bool {
        abs(milkAmount - targetMilkAmount) <= 0.1 &&
        abs(flourAmount - targetFlourAmount) <= 0.1 &&
        abs(sugarAmount - targetSugarAmount) <= 0.1
    }

    func startMixing() {
            showMixingView = true
        }

    func startDrag() {
        dragStartTime = Date()
    }

    func endCooking() {
        pancakeState = .idle
        timer?.invalidate()
    }
}

extension PancakeGameViewModel: GameViewModelProtocol {
    func setupGameView(messagesViewController: MessagesViewController) {
        let view = CrackEggsView(viewModel: self)
        messagesViewController.presentView(view)
    }
}
