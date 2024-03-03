import Foundation
import SwiftUI
import Combine

class PancakeGameViewModel: ObservableObject {
    var timer: Timer?
    var messagesViewController: MessagesViewController
    var conversationManager: ConversationManager?

    var pickedEggIndex: Int?
    let eggsToCrack: Int = 5
    @Published var gameState: GameState
    @Published var eggTimer: Double = 0
    @Published var eggsCracked: Int = 0
    @Published var eggs: [Egg] = []

    @Published var ingredientsDropped: Set<String> = []
    @Published var pancakes: [Pancake] = []
    @Published var currentOrder = PancakeOrder.generateRandomOrder()
    @Published var score: Int = 0
    @Published var currentStage: GameStage? = nil

    init(gameState: GameState, messagesViewController: MessagesViewController, timeLimit: Int = 300) {
        self.gameState = gameState
        self.messagesViewController = messagesViewController
        self.eggs = Array(repeating: Egg(), count: eggsToCrack)
    }

    // PANCAKES

    func pourBatter() {
        guard pancakes.count < 6 else { return }
        let index = pancakes.count
        let row = index / 3
        let column = index % 3

        let xPosition = 180 + CGFloat(column) * 63
        let yPosition = 450 + CGFloat(row) * 60

        let newPancake = Pancake(position: CGPoint(x: xPosition, y: yPosition), state: .batter, cookingProgress: 0.0, hasBeenFlipped: false)
        DispatchQueue.main.async {
            self.pancakes.append(newPancake)
            self.startPancakeTimer(for: newPancake.id)
        }
    }

    func startPancakeTimer(for pancakeID: UUID) {
        guard let index = pancakes.firstIndex(where: { $0.id == pancakeID }) else { return }

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            var pancake = self.pancakes[index]

            switch pancake.cookingTime {
            case 0..<4:
                pancake.state = .batter
            case 4..<5:
                pancake.state = .readyToFlip
            case 5..<10:
                if pancake.hasBeenFlipped { pancake.state = .flipped }
            case 10..<15:
                if pancake.hasBeenFlipped { pancake.state = .done }
            case 15...:
                pancake.state = .burned
            default:
                break
            }

            pancake.cookingTime += 1
            self.pancakes[index] = pancake
            self.checkIfAllPancakesAreBurned()
        }
    }

    func resetGame() {
        // TODO: add resetters
        print()
    }

    func endTurnForPlayer() {
        let score = calculateScore()

        if gameState.currentPlayer == "player1" {
            gameState.player1Score += score
            gameState.player1Played = true
            gameState.currentPlayer = "player2"
        } else {
            gameState.player2Score += score
            gameState.player2Played = true
            gameState.currentPlayer = "player1"
        }

        conversationManager?.sendUpdatedGameState()
        messagesViewController.updateAndSendGameState {
            DispatchQueue.main.async {
                // TODO: if this doesnt work just delete next line and add to line 90 in cook pancake view
                self.currentStage = .outcome
            }
    }
    }

    func checkIfAllPancakesAreBurned() {
        let allBurned = pancakes.allSatisfy { $0.state == .burned }
        if allBurned {
            let score = calculateScore()
            print("Score: \(score)")
            endTurnForPlayer()
        }
    }

    func calculateScore() -> Int {
        let donePancakes = pancakes.filter { $0.state == .done }.count
        self.score = donePancakes
        return donePancakes
    }

    func addTopping(toPancakeID id: UUID, topping: String) {
        if let index = pancakes.firstIndex(where: { $0.id == id }) {
            switch topping {
            case "chocolatechips":
                pancakes[index].type = .chocolateChip
            case "booberry":
                pancakes[index].type = .blueberry
            default:
                break
            }
        }
    }

    func cookPancake(id: UUID) {
        guard let index = pancakes.firstIndex(where: { $0.id == id }) else { return }
        var cookTimer: Timer?

        cookTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            var pancake = self.pancakes[index]

            if pancake.cookingProgress < 1.0 {
                pancake.cookingProgress += 1/6
                if pancake.cookingProgress >= 1.0 {
                    pancake.state = pancake.hasBeenFlipped ? .done : .readyToFlip
                    cookTimer?.invalidate()
                }
                self.pancakes[index] = pancake
            }
        }
    }

    func flipPancake(id: UUID) {
        guard let index = pancakes.firstIndex(where: { $0.id == id }), pancakes[index].state == .readyToFlip || pancakes[index].state == .flipped else { return }
         pancakes[index].hasBeenFlipped = true
         pancakes[index].cookingProgress = 0.0
         pancakes[index].state = .flipped
         cookPancake(id: id)
     }

    func moveToPlate(pancakeID: UUID) {
        guard let index = pancakes.firstIndex(where: { $0.id == pancakeID }),
              pancakes[index].state == .done else { return }

        let offsetX: CGFloat = CGFloat(pancakes.filter { $0.state == .done }.count * 1)
        let platePositionX: CGFloat = UIScreen.main.bounds.width / 1.47 - offsetX
        let platePositionY: CGFloat = 235

        DispatchQueue.main.async {
            self.pancakes[index].position = CGPoint(x: platePositionX, y: platePositionY)
        }
    }

    // EGGS

    func backgroundImageName() -> String {
        @ObservedObject var viewModel: PancakeGameViewModel
        // TODO: update to check for each indivudual ingrediant
        if ingredientsDropped.count == 3 {
            return "mixedbackground"
        } else if ingredientsDropped.contains("flour") {
            return "flourbackground"
        } else if ingredientsDropped.contains("milk") {
            return "milkbackground"
        } else if ingredientsDropped.contains("sugar") {
            return "sugarbackground"
        }

        return "eggybackground"
    }

    func isDropLocationCorrect(_ location: CGPoint, for ingredientName: String) -> Bool {
        let targetRect = CGRect(x: 100, y: 300, width: 200, height: 100)
        return targetRect.contains(location)
    }

    func resetEggs() {
         eggs = Array(repeating: Egg(), count: eggsToCrack)
     }

    func pickUpEgg(at index: Int) {
        guard eggs.indices.contains(index), eggs[index].state == .whole else { return }
        pickedEggIndex = index
    }

    func crackPickedEgg(at position: CGPoint) {
        eggsCracked += 1
        guard let index = pickedEggIndex else { return }
        eggs[index].state = .cracked
        eggs[index].position = position

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.eggs[index].state = .exploded
            }
        }
    }
}

extension PancakeGameViewModel: GameViewModelProtocol {
    func setupGameView(messagesViewController: MessagesViewController) {
        let view = CrackEggsView(viewModel: self, messagesViewController: messagesViewController)
        messagesViewController.presentView(view)
    }
}
