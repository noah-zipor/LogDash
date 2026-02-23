import SwiftUI
import CoreImage

struct FilmGrainView: View {
    static let noiseImage: Image? = {
        let filter = CIFilter(name: "CIRandomGenerator")
        if let outputImage = filter?.outputImage {
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
            if let cgImage = CIContext().createCGImage(outputImage, from: rect) {
                return Image(nsImage: NSImage(cgImage: cgImage, size: CGSize(width: 512, height: 512)))
            }
        }
        return nil
    }()

    var body: some View {
        if let noise = Self.noiseImage {
            GeometryReader { _ in
                noise
                    .resizable(resizingMode: .tile)
                    .opacity(0.04)
                    .blendMode(.screen)
                    .drawingGroup()
            }
            .ignoresSafeArea()
        }
    }
}

extension View {
    func filmGrain() -> some View {
        self.overlay(FilmGrainView().allowsHitTesting(false))
    }
}
