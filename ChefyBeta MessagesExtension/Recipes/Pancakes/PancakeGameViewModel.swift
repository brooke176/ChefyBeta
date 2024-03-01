import Foundation
import SwiftUI

enum EggState {
    case whole, cracked, exploded
}

struct Egg {
    var state: EggState = .whole
    var position: CGPoint?
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

struct Pancake: Identifiable {
    let id = UUID()
    var position: CGPoint
    var state: PancakeState = .batter
    var cookingProgress: Double = 0.0
    var hasBeenFlipped: Bool = false
    var cookingTime: TimeInterval = 0
}

enum PancakeState {
    case batter, cooking, readyToFlip, flipped, cooked, done, burned
}


class PancakeGameViewModel: ObservableObject {
    var timer: Timer?
    var pickedEggIndex: Int?
    let eggsToCrack: Int = 5
    
    @Published var gameState: GameState
    @Published var eggTimer: Double = 0
    @Published var eggsCracked: Int = 0
    @Published var eggs: [Egg] = []

    @Published var ingredientsDropped: Set<String> = []
    @Published var pancakes: [Pancake] = []
    
    @Published var showMixingView = false
    @Published var showCookingView = false
    @Published var showOutcomeView: Bool = false

    init(gameState: GameState, timeLimit: Int = 300) {
        self.gameState = gameState
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
    
    func moveToPlate(pancakeID: UUID) {
        guard let index = pancakes.firstIndex(where: { $0.id == pancakeID }),
              pancakes[index].state == .done else { return }

        let offsetX: CGFloat = CGFloat(pancakes.filter { $0.state == .done }.count * 1)
        let platePositionX: CGFloat = UIScreen.main.bounds.width / 1.5 - offsetX
        let platePositionY: CGFloat = 240

        DispatchQueue.main.async {
            self.pancakes[index].position = CGPoint(x: platePositionX, y: platePositionY)
        }
    }
    
    func servePancakes() {
        showOutcomeView = true
    }
    
    func startPancakeTimer(for pancakeID: UUID) {
            guard let index = pancakes.firstIndex(where: { $0.id == pancakeID }) else { return }

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                var pancake = self.pancakes[index]

                switch pancake.cookingTime {
                case 0..<4:
                    pancake.state = .batter
                case 4:
                    pancake.state = .readyToFlip
                case 5..<8 where pancake.hasBeenFlipped:
                    pancake.state = .cooking
                case 8 where pancake.hasBeenFlipped:
                    pancake.state = .done
                case 10:
                    pancake.state = .burned
                    timer.invalidate()
                    showOutcomeView = true
                default:
                    break
                }

                pancake.cookingTime += 1
                self.pancakes[index] = pancake
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
         guard let index = pancakes.firstIndex(where: { $0.id == id }), pancakes[index].state == .readyToFlip else { return }
         pancakes[index].hasBeenFlipped = true
         pancakes[index].cookingProgress = 0.0
         pancakes[index].state = .cooking
         cookPancake(id: id)
     }
    
    func finishCooking() {
        timer?.invalidate()
        showOutcomeView = true
        resetEggs()
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
        let view = CrackEggsView(viewModel: self)
        messagesViewController.presentView(view)
    }
}
