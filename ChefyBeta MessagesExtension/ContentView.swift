import SwiftUI
import Foundation
import Messages

struct ContentView: View {
    @State private var selectedItem: ImageItem?
    @State private var showGameView = false
    @State private var showingProfile = false
    @State private var showingSettings = false
    var conversation: MSConversation?
    var conversationManager: ConversationManager

    let imageItems: [ImageItem] = [
        ImageItem(id: 1, imageName: "steak 1", label: "Steak"),
        ImageItem(id: 2, imageName: "carbonara", label: "Carbonara"),
        ImageItem(id: 3, imageName: "beef_wellington", label: "Beef Welly"),
        ImageItem(id: 4, imageName: "california_roll", label: "Sushi"),
        ImageItem(id: 5, imageName: "nachos", label: "Nachos"),
        ImageItem(id: 6, imageName: "potato", label: "Potato"),
        ImageItem(id: 7, imageName: "cake", label: "Cake"),
        ImageItem(id: 8, imageName: "burrito", label: "Burrito")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ToolbarView(showProfile: {
                        self.showingProfile = true
                    }, showSettings: {
                        self.showingSettings = true
                    })
                    .sheet(isPresented: $showingProfile) {
                        ProfileView() // Your profile view here
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsView() // Your settings view here
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(imageItems, id: \.imageName) { item in
                            Button(action: {
                                if item.label == "Steak" {
                                    inviteToPlaySteakGame()
                                }
                            }) {
                                itemContent(for: item)
                            }
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                }
            }
        }
    }

    private func itemContent(for item: ImageItem) -> some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5))
                .shadow(radius: 1)
                .frame(width: 70, height: 80)
                .overlay(
                    item.label != "Steak" ?
                        Text("Coming Soon")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .padding(2)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .offset(x: 0, y: 6)
                        : nil,
                    alignment: .bottomTrailing
                )
            
            Text(item.label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(width: 60)
                .padding(.top, 2)
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
        .frame(width: 80, height: 120)
    }
    
    private func inviteToPlaySteakGame() {
            guard let conversation = conversation else { return }
            
            let session = MSSession()
            let message = MSMessage(session: session)
            let layout = MSMessageTemplateLayout()
            layout.caption = "Let's play Steak Game!!"
            message.layout = layout

            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "player1Score", value: "0"),
                URLQueryItem(name: "player2Score", value: "0"),
                URLQueryItem(name: "player1Played", value: "false"),
                URLQueryItem(name: "player2Played", value: "false")
            ]
            message.url = components.url

            conversation.insert(message) { error in
                if let error = error {
                    print("Error sending game invitation: \(error.localizedDescription)")
                }
            }
        }
}
