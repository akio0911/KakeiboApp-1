//
//  GradientLayerView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/07.
//

import UIKit

class GradientLayerView: UIView {
    func setGradientLayer(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        self.layer.addSublayer(gradientLayer)
    }
}
