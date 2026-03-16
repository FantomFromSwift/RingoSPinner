import Foundation
import SwiftUI

func adaptyH(_ baseSize: CGFloat) -> CGFloat {
    let baseScreenHeight: CGFloat = 844
    let rawHeight = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .screen.bounds.height ?? baseScreenHeight
    let screenHeight = rawHeight > 0 ? rawHeight : baseScreenHeight
    return (baseSize / baseScreenHeight) * screenHeight
}

func adaptyW(_ baseWidth: CGFloat) -> CGFloat {
    let baseScreenWidth: CGFloat = 390
    let rawWidth = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .screen.bounds.width ?? baseScreenWidth
    let screenWidth = rawWidth > 0 ? rawWidth : baseScreenWidth
    return (baseWidth / baseScreenWidth) * screenWidth
}
