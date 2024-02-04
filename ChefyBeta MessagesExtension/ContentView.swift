import SwiftUI
import Foundation
import Messages

struct ContentView: View {
    @State private var selectedItem: ImageItem?
    @State private var showGameView = false
    var conversation: MSConversation?

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
        if item.label == "Steak" {
            //            Button(action: {
            //                showGameView = true
            //            }) {
            //                itemContent(for: item)
            //            }
            //            .sheet(isPresented: $showGameView) {
            //                SteakGameView()
            //            }
            NavigationLink(destination: DetailView(item: item, conversation: conversation)) {
                itemContent(for: item)
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
}

#Preview {
    ContentView()
}
