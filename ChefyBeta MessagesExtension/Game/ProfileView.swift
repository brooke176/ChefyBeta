import SwiftUI

struct ProfileView: View {
    // Placeholder for user icon; replace with actual user icon retrieval
    let userIcon: Image = Image(systemName: "person.fill")

    // Placeholder for lifetime wins; replace with actual data retrieval
    let lifetimeWins: Int = 0 // This will be replaced with actual data retrieval logic
    
    // Environment to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            userIcon
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.bottom, 20)

            Text("Lifetime Wins: \(lifetimeWins)")
                .font(.headline)
                
            Button("Back") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
        // Removed the navigationBarTitle since it's not applicable for a modal sheet in SwiftUI
    }
}
