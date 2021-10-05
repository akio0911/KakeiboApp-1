//
//  ExtensionUIColor.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = CIColor(cgColor: self.cgColor)
        return (color.red, color.green, color.blue, color.alpha)
    }
}
