import SwiftUI

struct ProgressBar: View {
    var progress: Double // Between 0.0 and 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(self.progress > 0.8 ? .red : .green)
                    .animation(.linear, value: progress)
            }.cornerRadius(45.0)
        }
    }
}
