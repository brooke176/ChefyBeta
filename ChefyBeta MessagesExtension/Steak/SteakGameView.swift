import SwiftUI

struct GameButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

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

struct SteakGameView: View {
    @Binding var gameState: GameState
    var messagesViewController: MessagesViewController
    @State private var seasoning = SteakSeasoning()
    @State private var cookingProgress = 0.0
    @State private var isCooking = false
    @State private var steakFlipped = false
    @State private var gameEnded = false
    @State private var gameMessage = ""
    @State private var showFireEffect = false
    @State private var timer: Timer?
    @State private var seasoningGraphics: [SeasoningGraphic] = []
    @State private var score = 1
    @State private var playerScore = 0
    @State private var opponentScore: Int? = nil // Score of the opponent, nil if not yet played

    private let minSeasoningAmount: Double = 0.6
    private let maxSeasoningAmount = 3.0
    private let perfectSeasoningRange = 0.6...1.5
    private let maxCookingProgress = 1.0
    
    var body: some View {
        ZStack {
            contentStack
                .background(
                    Image("brick-3")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                )
        }
        .onAppear {
            // Additional setup if needed
        }
        .onChange(of: gameState) { _ in
            // React to changes in gameState if needed
        }
    }
    
    private var contentStack: some View {
        VStack {
            Spacer()
            Text(instructionText)
                .padding()
                .background(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .foregroundColor(.black)
                .padding([.leading, .trailing], 20)
                .cornerRadius(25)
            Spacer()
            gameViewContent.padding(.horizontal)
            actionButtons.padding()
            Spacer()
        }
    }
    
    private var gameViewContent: some View {
        ZStack(alignment: .center) {
            Image("stove2").resizable().scaledToFit().frame(width: 300, height: 317)
            Image("pan").resizable().scaledToFit().frame(width: 190, height: 190).offset(y: 20)
            Image("steak").resizable().scaledToFit().frame(width: 70, height: 70)
                .rotation3DEffect(.degrees(steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: steakFlipped)
            ForEach(seasoningGraphics.filter {
                let shouldDisplay = $0.side == (steakFlipped ? .back : .front)
                return shouldDisplay
            }) { graphic in
                Circle()
                    .fill(graphic.color)
                    .frame(width: 4, height: 4)
                    .position(graphic.position)
            }
            if showFireEffect {
                Image("fire").resizable().scaledToFit().frame(width: 150, height: 150)
            }
        }.onTapGesture {
            if isCooking { steakFlipped.toggle() }
        }
    }
    
    private var actionButtons: some View {
        VStack {
            startCookingButton
            serveSteakButton
            seasoningButtons
            ProgressBar(progress: cookingProgress).frame(height: 20).padding()
        }
    }
    
    private var canStartCooking: Bool {
        seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount
    }
    
    private var startCookingButton: some View {
        Button("Start Cooking", action: startCooking)
            .disabled(!canStartCooking)
            .buttonStyle(GameButtonStyle(backgroundColor: .green))
    }
    
    private var serveSteakButton: some View {
            Button("Serve Steak", action: serveSteak)
            .disabled(!isCooking)
            .buttonStyle(GameButtonStyle(backgroundColor: .blue))
    }
    
    private var seasoningButtons: some View {
        HStack(spacing: 10) {
            Image("salt")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 85)
                .padding(.top, 30)
                .onTapGesture {
                    self.addSeasoningGraphics(type: .salt)
                }
            
            Image("pepper")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 85)
                .padding(.top, 30)
                .onTapGesture {
                    self.addSeasoningGraphics(type: .pepper)
                }
        }
    }
    
    private var instructionText: String {
        if gameEnded {
            if (gameState.player2Score != 0) {
                if gameState.player1Score > gameState.player2Score {
                    return "You won! 🎉"
                } else if gameState.player1Score < gameState.player2Score {
                    return "You lost. Try again!"
                } else {
                    return "It's a tie!"
                }
            } else {
                return "Waiting for opponent..."
            }
        } else {
            switch gameState.currentPlayer {
            case "player1":
                if gameState.player1Played {
                    return "You've played your turn. Waiting for Player 2."
                } else {
                    return "It's your turn, Player 1! Season and cook the steak."
                }
            case "player2":
                if gameState.player2Played {
                    return "You've played your turn. Waiting for Player 1."
                } else {
                    return "It's your turn, Player 2! Season and cook the steak."
                }
            default:
                return "Prepare to cook!"
            }
        }
    }
    
    private func addSeasoningGraphics(type: SeasoningType) {
        let addAmount: Double = 0.1 * 3
        let seasoningColor = type == .salt ? Color.white : Color.black
        let side: SteakSide = steakFlipped ? .back : .front
        switch (type, side) {
        case (.salt, .front):
            seasoning.frontSalt = min(seasoning.frontSalt + addAmount, maxSeasoningAmount)
        case (.salt, .back):
            seasoning.backSalt = min(seasoning.backSalt + addAmount, maxSeasoningAmount)
        case (.pepper, .front):
            seasoning.frontPepper = min(seasoning.frontPepper + addAmount, maxSeasoningAmount)
        case (.pepper, .back):
            seasoning.backPepper = min(seasoning.backPepper + addAmount, maxSeasoningAmount)
        }
        
        if (type == .salt && (seasoning.frontSalt <= maxSeasoningAmount || seasoning.backSalt <= maxSeasoningAmount)) ||
            (type == .pepper && (seasoning.frontPepper <= maxSeasoningAmount || seasoning.backPepper <= maxSeasoningAmount)) {
            for _ in 1...3 {
                let offsetAmount: CGFloat = 20.0
                let newPosition = CGPoint(x: CGFloat.random(in: 175...215) - offsetAmount,
                                          y: CGFloat.random(in: 180...195) - offsetAmount)
                
                seasoningGraphics.append(SeasoningGraphic(position: newPosition, color: seasoningColor, type: type, side: side))
            }
        }
    }
    
    private func startCooking() {
            isCooking = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.cookingProgress += 0.1
                if self.cookingProgress >= self.maxCookingProgress {
                    self.showFireEffect = true
                    self.endTurnForPlayer()
                }
            }
        }
        
        private func serveSteak() {
            endTurnForPlayer()
        }
    
    private func resetGame() {
            cookingProgress = 0
            isCooking = false
            steakFlipped = false
            gameEnded = false
            showFireEffect = false
            seasoningGraphics = []
        }
    
    private func endTurnForPlayer() {
        let isFrontSeasoned = seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount
        let isBackSeasoned = seasoning.backSalt >= minSeasoningAmount && seasoning.backPepper >= minSeasoningAmount
        let cookingCorrectlyDone = cookingProgress >= 0.6 && cookingProgress <= 0.8
        let perfectScore = isFrontSeasoned && isBackSeasoned && cookingCorrectlyDone
        let okScore = steakFlipped && (isFrontSeasoned || isBackSeasoned) && cookingCorrectlyDone
        let score = perfectScore ? 3 : okScore ? 2 : 1
        
        if gameState.currentPlayer == "player1" {
            gameState.player1Score += score
            gameState.player1Played = true
            gameState.currentPlayer = "player2" // Switch to the next player
        } else if gameState.currentPlayer == "player2" {
            gameState.player2Score += score // Same as above for player 2
            gameState.player2Played = true
            gameState.currentPlayer = nil
        }

        resetGame()

        messagesViewController.gameState = gameState
        messagesViewController.updateAndSendGameState()
    }

    private func checkGameEnd() {
        if gameState.player1Played && gameState.player2Played {
            gameEnded = true
            gameMessage = determineWinner()
        }
    }
    
    func determineWinner() -> String {
        if gameState.player1Played && gameState.player2Played {
            if gameState.player1Score > gameState.player2Score {
                return "Player 1 wins with a score of \(gameState.player1Score)!"
            } else if gameState.player2Score > gameState.player1Score {
                return "Player 2 wins with a score of \(gameState.player2Score)!"
            } else {
                return "It's a tie!"
            }
        }
        return "Game is not yet completed."
    }
}
