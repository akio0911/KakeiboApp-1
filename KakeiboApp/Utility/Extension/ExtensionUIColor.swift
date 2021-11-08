//
//  ExtensionUIColor.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

extension UIColor {
    // swiftlint:disable:next large_tuple
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var gotHue: CGFloat = 0
        var gotSaturation: CGFloat = 0
        var gotBrightness: CGFloat = 0
        var gotAlpha: CGFloat = 0
        self.getHue(&gotHue, saturation: &gotSaturation, brightness: &gotBrightness, alpha: &gotAlpha)
        return (hue: gotHue, saturation: gotSaturation, brightness: gotBrightness, alpha: gotAlpha)
    }

    var hex: String {
        if let components = self.cgColor.components {
            let red = String(Int(round(components[0] * 255)), radix: 16)
            let green = String(Int(round(components[1] * 255)), radix: 16)
            let blue = String(Int(round(components[2] * 255)), radix: 16)
            return red + green + blue
        }
        return "000000"
    }
}
