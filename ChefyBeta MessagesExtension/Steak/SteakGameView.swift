//import SwiftUI
//import os.log
//
//    struct GameButtonStyle: ButtonStyle {
//        var backgroundColor: Color
//        var isDisabled: Bool = false
//
//        func makeBody(configuration: Self.Configuration) -> some View {
//            configuration.label
//                .padding()
//                .background(isDisabled ? backgroundColor.opacity(0.5) : backgroundColor)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//                .scaleEffect(configuration.isPressed ? 0.95 : 1)
//                .animation(.easeInOut, value: configuration.isPressed)
//        }
//    }
//
//
//struct GameState: Equatable {
//    var player1Score: Int = 0
//    var player2Score: Int = 0
//    var player1Played: Bool = false
//    var player2Played: Bool = false
//    var currentPlayer: String?
//}
//
////struct SteakSeasoning {
////    var frontSalt: Double = 0
////    var backSalt: Double = 0
////    var frontPepper: Double = 0
////    var backPepper: Double = 0
////}
////
////enum SeasoningType {
////    case salt, pepper
////}
//
//struct SteakGameView: View {
//    @Binding var gameState: GameState
//    var messagesViewController: MessagesViewController
//    @State private var seasoning = SteakSeasoning()
//    @State private var cookingProgress = 0.0
//    @State private var isCooking = false
//    @State private var steakFlipped = false
//    @State private var gameEnded = false
//    @State private var gameMessage = ""
//    @State private var showFireEffect = false
//    @State private var timer: Timer?
//    @State private var seasoningGraphics: [SeasoningGraphic] = []
//    @State private var showingLoadingOverlay = false
//    @State private var showOutcomeView = false
//    
//    private let minSeasoningAmount: Double = 0.6
//    private let maxSeasoningAmount = 3.0
//    private let perfectSeasoningRange = 0.6...1.5
//    private let maxCookingProgress = 1.0
//    
//    var body: some View {
//        ZStack {
//            Image("seasonSteakBackground")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
//            contentStack
//                .padding(.horizontal)
//                .padding(.top, 20)
//            if showingLoadingOverlay {
//                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
//                VStack {
//                    Text("Loading...").foregroundColor(.white).padding()
//                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
//                }
//                .frame(width: 150, height: 150)
//                .background(Color.secondary.colorInvert())
//                .cornerRadius(20).shadow(radius: 10)
//            }
//        }
//        .onAppear {
//            // Additional setup if needed
//        }
//        .onChange(of: gameState) {
//            // React to changes in gameState if needed
//        }
//        .sheet(isPresented: $showOutcomeView) { // This presents the outcome view
//            GameOutcomeView(gameState: gameState) // Make sure GameOutcomeView accepts a Binding<GameState>
//        }
//    }
//    
//    private var contentStack: some View {
//        VStack {
//            Spacer()
//            Text(instructionText)
//                .padding()
//                .background(Color.white.opacity(0.8)) // Lighter background for better readability
//                .foregroundColor(Color.black) // Ensuring the text color is black for contrast
//                .font(.headline) // Use a slightly larger font for better visibility
//                .cornerRadius(10) // Softer corners
//                .shadow(radius: 5) // Subtle shadow for a lifted look
//                .padding(.horizontal, 10) // Adjust horizontal padding for better alignment
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10) // Matching corner radius with the background
//                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2) // Gradient border for a modern look
//                )
//                .padding(.vertical, 5) // Adjust vertical padding to balance the layout
//            Spacer()
//            gameViewContent.padding(.horizontal)
//            Spacer()
//                .padding(.vertical, 5) // Adjust vertical padding to balance the layout
//            actionButtons.padding()
//            Spacer()
//        }
//    }
//    
//    private var gameViewContent: some View {
//        ZStack(alignment: .center) {
//            Image("steakie")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 175, height: 175)
//                .offset(x: 0, y: -150) // Adjusted offset for the steak image
//                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2) // Example fixed position
//                .rotation3DEffect(.degrees(steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
//                .animation(.easeInOut(duration: 0.5), value: steakFlipped)
//                .onTapGesture {
//                    if isCooking { steakFlipped.toggle() }
//                }
//            
//            ForEach(seasoningGraphics.filter { $0.side == (steakFlipped ? .back : .front) }) { graphic in
//                Circle()
//                    .fill(graphic.color)
//                    .frame(width: 4, height: 4)
//                    .position(graphic.position)
//            }
//            
//            Rectangle()
//                .fill(Color.red) // Making the rectangle invisible
//                .frame(width: 80, height: 80) // Match the salt button size for consistency
//                .offset(x: -105, y: 75) // Place it over the salt area
//                .onTapGesture {
//                    print("Salt area tapped")
//                    self.addSeasoningGraphics(type: .salt)
//                }
//            
//            // Pepper Area Tap Gesture
//            Rectangle()
//                .fill(Color.blue) // Making the rectangle invisible
//                .frame(width: 80, height: 80) // Match the pepper button size for consistency
//                .offset(x: 135, y: 275) // Adjust this to place it over the pepper area accurately
//                .onTapGesture {
//                    print("Pepper area tapped")
//                    self.addSeasoningGraphics(type: .pepper)
//                }
//        }
//    }
//    
//    private var actionButtons: some View {
//        VStack {
//            startCookingButton
//            serveSteakButton
//            ProgressBar(progress: cookingProgress).frame(height: 20).padding()
//        }
//    }
//    
//    var canStartCooking: Bool {
//        seasoning.frontSalt >= minSeasoningAmount
//    }
//    
//    private var startCookingButton: some View {
//        Button("Start Cooking", action: startCooking)
//            .disabled(!canStartCooking)
//            .buttonStyle(GameButtonStyle(backgroundColor: .green))
//    }
//    
//    private var serveSteakButton: some View {
//        Button("Serve Steak", action: endTurnForPlayer)
//            .disabled(!isCooking)
//            .buttonStyle(GameButtonStyle(backgroundColor: .blue))
//    }
//    
//    private var instructionText: String {
//        if gameEnded {
//            if (gameState.player2Score != 0) {
//                if gameState.player1Score > gameState.player2Score {
//                    return "You won! 🎉"
//                } else if gameState.player1Score < gameState.player2Score {
//                    return "You lost. Try again!"
//                } else {
//                    return "It's a tie!"
//                }
//            } else {
//                return "Waiting for opponent..."
//            }
//        } else if !isCooking {
//            if seasoning.frontSalt < minSeasoningAmount || seasoning.frontPepper < minSeasoningAmount {
//                return "Season the steak"
//            } else {
//                return "Start cooking the steak"
//            }
//        } else {
//            if !steakFlipped {
//                return "Flip the steak"
//            } else if steakFlipped && seasoning.backSalt < minSeasoningAmount || seasoning.backPepper < minSeasoningAmount {
//                return "Season the back side of the steak"
//            } else if cookingProgress < 0.6 {
//                return "Keep cooking..."
//            } else {
//                return "Serve the steak"
//            }
//        }
//    }
//    
//    
//    private func addSeasoningGraphics(type: SeasoningType) {
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//        let addAmount: Double = 0.1 * 5
//        let seasoningColor = type == .salt ? Color.white : Color.black
//        let side: SteakSide = steakFlipped ? .back : .front
//        switch (type, side) {
//        case (.salt, .front):
//            seasoning.frontSalt = min(seasoning.frontSalt + addAmount, maxSeasoningAmount)
//        case (.salt, .back):
//            seasoning.backSalt = min(seasoning.backSalt + addAmount, maxSeasoningAmount)
//        case (.pepper, .front):
//            seasoning.frontPepper = min(seasoning.frontPepper + addAmount, maxSeasoningAmount)
//        case (.pepper, .back):
//            seasoning.backPepper = min(seasoning.backPepper + addAmount, maxSeasoningAmount)
//        }
//        
//        for _ in 1...5 {
//            let newPosition = CGPoint(x: CGFloat.random(in: 150...270),
//                                      y: CGFloat.random(in: 245...310))
//            
//            seasoningGraphics.append(SeasoningGraphic(position: newPosition, color: seasoningColor, type: type, side: side))
//        }
//    }
//    
//    private func startCooking() {
//        isCooking = true
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            self.cookingProgress += 0.1
//            if self.cookingProgress >= self.maxCookingProgress {
//                self.showFireEffect = true
//                self.endTurnForPlayer()
//            }
//        }
//    }
//    
//    private func resetGame() {
//        cookingProgress = 0
//        isCooking = false
//        steakFlipped = false
//        gameEnded = false
//        showFireEffect = false
//        seasoningGraphics = []
//    }
//    
//    private func endTurnForPlayer() {
//        showingLoadingOverlay = true
//        
//        if gameState.currentPlayer == "player1" {
//            gameState.player1Score = 2
//            gameState.player1Played = true
//        } else if gameState.currentPlayer == "player2" {
//            gameState.player2Score = 3
//            gameState.player2Played = true
//        }
//        self.resetGame()
//        
//        messagesViewController.gameState = gameState
//        messagesViewController.updateAndSendGameState {
//            DispatchQueue.main.async {
//                self.showOutcomeView = true
//            }
//        }
//    }
//}
