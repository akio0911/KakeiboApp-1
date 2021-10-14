//
//  ExtensionUIColor.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

extension UIColor {
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: h, saturation: s, brightness: b, alpha: a)
    }

    var hex: String {
        if let components = self.cgColor.components {
            let r = String(Int(round(components[0] * 255)), radix: 16)
            let g = String(Int(round(components[1] * 255)), radix: 16)
            let b = String(Int(round(components[2] * 255)), radix: 16)
            return r + g + b
        }
        return "000000"
    }
}
