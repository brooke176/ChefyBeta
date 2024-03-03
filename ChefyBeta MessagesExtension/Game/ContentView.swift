import SwiftUI
import Foundation
import Messages

struct ContentView: View {
    @State private var selectedItem: ImageItem?
    @State private var showingProfile = false
    @State private var showingSettings = false
    private var conversationManager: ConversationManager?

    init(conversation: MSConversation?) {
        self.conversationManager = ConversationManager(conversation: conversation)
    }

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
                        ProfileView()
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsView()
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(imageItems, id: \.imageName) { item in
                            Button(action: {
                                selectedItem = item
                                self.conversationManager?.inviteToGame(for: item)
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
                    item.label != "Beef Welly" && item.label != "Pancakes" ?
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
}
