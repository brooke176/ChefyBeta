import SwiftUI

struct SettingsView: View {
    let userIcon: Image = Image(systemName: "person.fill")
    let lifetimeWins: Int = 0 // This will be replaced with actual data retrieval logic
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
    }
}
