import SwiftUI
import Foundation
import Messages

struct ContentView: View {
    @State private var selectedItem: ImageItem?
    @State private var showGameView = false
    var conversation: MSConversation?

    let imageItems: [ImageItem] = [
        ImageItem(id: 1, imageName: "burger", label: "Burger"),
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
                    ToolbarView()
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(imageItems, id: \.imageName) { item in
                            itemContainer(item: item)
                        }
                    }
                    //                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
    }

    @ViewBuilder
    private func itemContainer(item: ImageItem) -> some View {
        if item.label == "Burger" {
            Button(action: {
                showGameView = true
            }) {
                itemContent(for: item)
            }
            .sheet(isPresented: $showGameView) {
                SteakGameView()
            }
        } else {
            NavigationLink(destination: DetailView(item: item, conversation: conversation)) {
                itemContent(for: item)
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
                .shadow(radius: 1) // Reduce shadow radius for subtlety
                .frame(width: 60, height: 60) // Adjust image size for compactness

            Text(item.label)
                .font(.system(size: 10, weight: .medium, design: .rounded)) // Slightly reduce font size
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(width: 60) // Keep text width aligned with image width
                .padding(.top, 2) // Minimize padding between image and text
        }
        .padding(8) // Minimize overall padding
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
        // Adjust overall frame to be more compact
        .frame(width: 80, height: 120) // Adjust overall size for compactness
    }
}

#Preview {
    ContentView()
}
