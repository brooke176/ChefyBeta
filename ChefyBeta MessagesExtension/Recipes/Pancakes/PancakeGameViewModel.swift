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

class PancakeGameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var pancakeState: pancakeState
    @Published var eggTimer: Double = 0
    @Published var showMixerView: Bool = false
    @Published var showOutcomeView: Bool = false
    @Published var eggsCracked: Int = 0
    @Published var currentEggState: EggState = .whole
    @Published var showMixingView = false

    let eggsToCrack: Int = 5
    var dragStartTime: Date?
    var timer: Timer?

    init(gameState: GameState) {
        self.gameState = gameState
        self.pancakeState = .idle
    }

    func startCooking() {
        pancakeState = .cooking
        eggsCracked = 0
        showOutcomeView = false
        eggTimer = 30.0

        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.eggTimer -= 1
            if self.eggTimer <= 0 {
                self.timer?.invalidate()
                self.pancakeState = .finished
                self.showOutcomeView = true
            }
        }
    }

    func startDrag() {
        dragStartTime = Date()
    }

    func resetEggState() {
        self.currentEggState = .whole
    }

    func handleDrop() {
            applyForce()
        }

        func applyForce() {
            if eggsCracked < eggsToCrack {
                currentEggState = .cracked
                eggsCracked += 1
            }

            if eggsCracked >= eggsToCrack {
                timer?.invalidate()
                pancakeState = .finished
                showOutcomeView = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.resetEggState()
            }
        }

    func endCooking() {
        pancakeState = .idle
        timer?.invalidate()
    }

    func startMixing() {
        showMixingView = true
//        timer?.invalidate()
    }
}

extension PancakeGameViewModel: GameViewModelProtocol {
    func setupGameView(messagesViewController: MessagesViewController) {
        let view = CrackEggsView(viewModel: self)
        messagesViewController.presentView(view)
    }
}
