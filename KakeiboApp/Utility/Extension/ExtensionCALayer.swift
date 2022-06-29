//
//  ExtensionCALayer.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/25.
//

import UIKit

extension CALayer {
    @objc dynamic var borderUIColor: UIColor? {
        get {
            guard let borderColor = self.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            self.borderColor = newValue?.cgColor
        }
    }

    @objc dynamic var shadowUIColor: UIColor? {
        get {
            guard let shadowColor = self.shadowColor else {
                return nil
            }
            return UIColor(cgColor: shadowColor)
        }
        set {
            self.shadowColor = newValue?.cgColor
        }
    }
}
