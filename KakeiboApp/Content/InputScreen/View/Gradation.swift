//
//  Gradation.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/03.
//

import UIKit
struct Gradation {
    
    let gradientLayer = CAGradientLayer()
    
    init() {
        let topColor = UIColor(red: 255 / 255, green: 129 / 255, blue: 51 / 255, alpha: 1)
        let bottomColor = UIColor(red: 255 / 255, green: 230 / 255, blue: 214 / 255, alpha: 1)
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.colors = gradientColors
        
    }
}
