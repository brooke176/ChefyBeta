import SwiftUI

struct ProgressBar: View {
    var progress: Double

    private let yellowZone = 0.0...0.6
    private let greenZone = 0.6...0.8
    private let redZone = 0.8...1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .border(Color.gray)

                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(progress <= yellowZone.upperBound ? .yellow : .clear)
                        .frame(width: geometry.size.width * CGFloat(min(self.progress, yellowZone.upperBound)))

                    Rectangle()
                        .foregroundColor(progress > yellowZone.upperBound && progress <= greenZone.upperBound ? .green : .clear)
                        .frame(width: geometry.size.width * CGFloat(max(min(self.progress - yellowZone.upperBound, greenZone.upperBound - yellowZone.upperBound), 0)))

                    Rectangle()
                        .foregroundColor(progress > greenZone.upperBound ? .red : .clear)
                        .frame(width: geometry.size.width * CGFloat(max(self.progress - greenZone.upperBound, 0)))
                }
            }
            .cornerRadius(45 / 2)
        }
        .frame(height: 45)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        // Pass a sample progress value to the ProgressBar for the preview
        ProgressBar(progress: 0.5) // Example with 50% progress
            .frame(height: 20) // Optional: Adjust the frame height as needed for your preview
            .padding() // Optional: Add padding around the ProgressBar in the preview
    }
}
