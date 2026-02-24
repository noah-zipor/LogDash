import SwiftUI
import AppKit

struct LogoView: View {
    let size: CGFloat
    
    var body: some View {
        Group {
            if let logoUrl = Bundle.module.url(forResource: "icon", withExtension: "png"),
               let logoImage = NSImage(contentsOf: logoUrl) {
                Image(nsImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let namedIcon = NSImage(named: "icon") {
                Image(nsImage: namedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.5, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .frame(width: size, height: size)
    }
}
