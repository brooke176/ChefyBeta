import Foundation
import Messages

class ConversationManager {
    weak var conversation: MSConversation?
    var onInvitationSent: (() -> Void)?
    var gameState: GameState = GameState()

    init(conversation: MSConversation?) {
        self.conversation = conversation
    }
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    func updateGameState(newGameState: GameState) {
        self.gameState = newGameState
    }

     func inviteToGame(for item: ImageItem) {
        print(item.label)
        inviteToGame(gameType: item.label)
    }

    func inviteToGame(gameType: String) {
        guard let conversation = conversation else { return }

        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = "Let's play \(gameType)!!"
        message.layout = layout

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "gameType", value: gameType.lowercased()),
            URLQueryItem(name: "player1Score", value: "0"),
            URLQueryItem(name: "player2Score", value: "0"),
            URLQueryItem(name: "player1Played", value: "true"),
            URLQueryItem(name: "player2Played", value: "false"),
            URLQueryItem(name: "currentPlayer", value: "player1"),
            URLQueryItem(name: "player1Id", value: conversation.localParticipantIdentifier.uuidString)
        ]
        message.url = components.url

        conversation.insert(message) { error in
            if let error = error {
                print("Error sending game invitation: \(error.localizedDescription)")
            }
        }
    }

    func decodeSelectedGameType(from conversation: MSConversation) -> GameType? {
        guard let messageURL = conversation.selectedMessage?.url,
              let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else { return nil }

        for queryItem in queryItems {
            if queryItem.name == "gameType", let value = queryItem.value {
                return GameType(rawValue: value)
            }
        }

        return nil
    }

    func decodeGameState(from url: URL, completion: @escaping (GameState?) -> Void) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            completion(nil)
            return
        }

        var gameState = GameState()

        for item in queryItems {
            switch item.name {
            case "gameType": gameState.gameType = item.value
            case "player1Score": gameState.player1Score = Int(item.value ?? "0") ?? 0
            case "player2Score": gameState.player2Score = Int(item.value ?? "0") ?? 0
            case "player1Played": gameState.player1Played = item.value == "true"
            case "player2Played": gameState.player2Played = item.value == "true"
            case "currentPlayer": gameState.currentPlayer = item.value ?? "player1"
            case "player1Id": gameState.player1Id = item.value // Add this line
            default:
                break
            }
        }

        completion(gameState)
    }

}
