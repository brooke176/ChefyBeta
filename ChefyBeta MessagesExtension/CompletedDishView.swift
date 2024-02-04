import Foundation
import SwiftUI

struct CompletedDishView: View {
    var score: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        VStack {
            HStack {
                ForEach(1..<4) { index in
                    Image(systemName: index <= score ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
            Text(score == 3 ? "Perfect Steak! <3" : score == 2 ? "Decent Steak...a little dry :/" : "Absolutely Revolting")

                .padding()

            Image(score == 3 ? "perfect-steak" : score == 2 ? "ok-steak" : "bad-steak")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Button("Try Again") {
                presentationMode.wrappedValue.dismiss()
            }

            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

// #Preview {
//    CompletedDishView()
// }
