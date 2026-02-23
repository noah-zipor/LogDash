import SwiftUI

extension Animation {
    static func cubicEaseOut(duration: Double) -> Animation {
        return Animation.timingCurve(0.215, 0.61, 0.355, 1, duration: duration)
    }
}
