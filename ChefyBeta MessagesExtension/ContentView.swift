import SwiftUI
import Foundation
import Messages

struct ContentView: View {
    @State private var selectedItem: ImageItem?
    var conversation: MSConversation?
    
    let imageItems: [ImageItem] = [
        ImageItem(id: 1, imageName: "beef_wellington", label: "Beef Wellington"),
        ImageItem(id: 2, imageName: "carbonara", label: "Carbonara"),
        ImageItem(id: 3, imageName: "cheeseburger", label: "Cheeseburger"),
        ImageItem(id: 4, imageName: "california_roll", label: "California Roll"),
        ImageItem(id: 5, imageName: "nachos", label: "Nachos"),
        ImageItem(id: 6, imageName: "potato", label: "Potato"),
        ImageItem(id: 7, imageName: "cake", label: "Cake"),
        ImageItem(id: 8, imageName: "burrito", label: "Burrito"),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ToolbarView() // Add the top bar view
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(imageItems, id: \.imageName) { item in
                            NavigationLink(destination: DetailView(item: item)) {
                                VStack {
                                    Image(item.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .border(Color.black, width: 1)

                                    Text(item.label)
                                        .font(.caption)
                                        .foregroundColor(.black)
//                                        .padding(.top, 5)
                                }
                            }
                        }
                    }
                    .padding(.top, -10) // Adjust this value to reduce top padding
//                  .navigationBarTitle("Menu")
                }
            }
            .sheet(item: $selectedItem) { item in
                DetailView(item: item, conversation: conversation)
            }
        }
    }
}


#Preview {
    ContentView()
}
