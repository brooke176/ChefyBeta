import Foundation
import SwiftUI

struct ToolbarView: View {
    let showProfile: () -> Void
    let showSettings: () -> Void
    
    var body: some View {
        HStack {
            Button(action: showProfile) {
                Image(systemName: "person.circle") // Profile icon
                Text("Profile")
            }

            Spacer()

            Button(action: showSettings) {
                Image(systemName: "gear") // Settings icon
                Text("Settings")
            }
        }
        .padding()
    }
}
