import SwiftUI
import Messages

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
    var conversationManager: ConversationManager

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
    @State private var showingCompletedDishView = false
    
    private let minSeasoningAmount: Double = 0.6
    private let maxSeasoningAmount = 3.0
    private let perfectSeasoningRange = 0.6...1.5
    private let maxCookingProgress = 1.0
    
    init(conversationManager: ConversationManager) {
        self.conversationManager = conversationManager
    }
    
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
        .sheet(isPresented: $showingCompletedDishView) {
            CompletedDishView(score: score)
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
    
    private var canStartCooking: Bool {
        seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount
    }
    
    private var instructionText: String {
        if gameEnded {
            return gameMessage
        } else if !isCooking {
            if seasoning.frontSalt < minSeasoningAmount || seasoning.frontPepper < minSeasoningAmount {
                return "Season the steak"
            } else {
                return "Start cooking the steak"
            }
        } else {
            if !steakFlipped {
                return "Flip the steak"
            } else if steakFlipped && seasoning.backSalt < minSeasoningAmount || seasoning.backPepper < minSeasoningAmount {
                return "Season the back side of the steak"
            } else if cookingProgress < 0.6 {
                return "Keep cooking..."
            } else {
                return "Serve the steak"
                
            }}
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
                self.timer?.invalidate()
                self.gameEnded = true
                self.calculateScore()
                self.showingCompletedDishView = true
                resetGame()
            }
        }
    }
    
    private func serveSteak() {
        stopCooking()
        calculateScore()
        gameEnded = true
        showingCompletedDishView = true
        resetGame()
    }
    
    func updateGameState() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = "Steak Cooking Game!"
        message.layout = layout
        
        // Encode your game state into a URL
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "frontSalt", value: String(seasoning.frontSalt)),
            URLQueryItem(name: "backSalt", value: String(seasoning.backSalt)),
            URLQueryItem(name: "frontPepper", value: String(seasoning.frontPepper)),
            URLQueryItem(name: "backPepper", value: String(seasoning.backPepper)),
            URLQueryItem(name: "cookingProgress", value: String(cookingProgress)),
            URLQueryItem(name: "score", value: String(score))
        ]
        
        message.url = components.url
        
        return message
    }
    
    private func stopCooking() {
        isCooking = false
        timer?.invalidate()
        timer = nil
        conversationManager.sendGameState(score: score) { error in
               if let error = error {
                   print("Error sending game state: \(error.localizedDescription)")
               } else {
                   // Handle successful sending, such as preparing for the next turn or showing a confirmation
               }
           }
       }
    
    private func resetGame() {
        cookingProgress = 0
        isCooking = false
        steakFlipped = false
        gameEnded = false
        showFireEffect = false
        seasoningGraphics = []
    }
    
    private func checkCookingProgress(_ newValue: Double) {
        if newValue >= maxCookingProgress {
            stopCooking()
            gameEnded = true
            calculateScore()
            showingCompletedDishView = true
        }
    }
    
    private func calculateScore() {
        let isFrontSeasoned = seasoning.frontSalt >= minSeasoningAmount && seasoning.frontPepper >= minSeasoningAmount
        let isBackSeasoned = seasoning.backSalt >= minSeasoningAmount && seasoning.backPepper >= minSeasoningAmount
        let cookingCorrectlyDone = cookingProgress >= 0.6 && cookingProgress <= 0.8
        let perfectScore = isFrontSeasoned && isBackSeasoned && cookingCorrectlyDone
        let okScore = steakFlipped && (isFrontSeasoned || isBackSeasoned) && cookingCorrectlyDone
        score = perfectScore ? 3 : okScore ? 2 : 1
    }
    
    func sendGameState(conversation: MSConversation) {
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = "Steak Cooking Challenge!"
        message.layout = layout
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "frontSalt", value: "\(seasoning.frontSalt)"),
            URLQueryItem(name: "backSalt", value: "\(seasoning.backSalt)"),
            URLQueryItem(name: "frontPepper", value: "\(seasoning.frontPepper)"),
            URLQueryItem(name: "backPepper", value: "\(seasoning.backPepper)"),
            URLQueryItem(name: "score", value: "\(score)"),
            // Add more game state components as needed
        ]
        
        message.url = components.url
        
        // Send the message
        conversation.insert(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

//struct SteakGameView_Previews: PreviewProvider {
//    static var previews: some View {
//        SteakGameView()
//    }
//}

// This extension could be part of your SteakGameView or a separate utility class

