import Foundation
import Messages

class ConversationManager {
    weak var conversation: MSConversation?
    var onInvitationSent: (() -> Void)?
    var gameState: GameState = GameState()

    init(conversation: MSConversation?) {
        self.conversation = conversation
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
            URLQueryItem(name: "player1Played", value: "false"),
            URLQueryItem(name: "player2Played", value: "false"),
            URLQueryItem(name: "currentPlayer", value: "player1")
        ]
        message.url = components.url

        conversation.insert(message) { error in
            if let error = error {
                print("Error sending game invitation: \(error.localizedDescription)")
            }
        }
    }
    
    func sendUpdatedGameState() {
        guard let conversation = conversation else { return }
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = gameState.currentPlayer == "player1" ? "Player 1's Turn" : "Player 2's Turn"
        message.layout = layout

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "gameType", value: gameState.gameType),
            URLQueryItem(name: "player1Score", value: String(gameState.player1Score)),
            URLQueryItem(name: "player2Score", value: String(gameState.player2Score)),
            URLQueryItem(name: "player1Played", value: String(gameState.player1Played)),
            URLQueryItem(name: "player2Played", value: String(gameState.player2Played)),
            URLQueryItem(name: "currentPlayer", value: gameState.currentPlayer)
        ]
        message.url = components.url

        conversation.insert(message) { error in
            if let error = error {
                print("Error sending updated game state: \(error.localizedDescription)")
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
            default:
                break
            }
        }

        completion(gameState)
    }

}
