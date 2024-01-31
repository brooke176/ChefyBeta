import SwiftUI

struct ToolbarView: View {
    var body: some View {
        HStack {
            Button(action: {
                // Add action for Profile
                print("Profile Tapped")
            }) {
                Image(systemName: "person.circle") // Replace with your profile icon
                Text("Profile")
            }

            Spacer()

            Button(action: {
                // Add action for Settings
                print("Settings Tapped")
            }) {
                Image(systemName: "gear") // Replace with your settings icon
                Text("Settings")
            }
        }
        .padding()
    }
}
