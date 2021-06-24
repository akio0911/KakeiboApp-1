//
//  CategoryGraphInfo.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/11.
//

import UIKit

struct CategoryGraphInfo {
    let color: UIColor
    let lastPercent: Double
    let nextPercent: Double

    var startAngle: CGFloat {
        angle(percent: lastPercent)
    }

    var endAngle: CGFloat {
        angle(percent: nextPercent)
    }

    private func angle(percent: Double) -> CGFloat {
        CGFloat(2*Double.pi*percent/100 - Double.pi/2)
    }

    init(color: UIColor, lastPercent: Double, nextPercent: Double) {
        self.color = color
        self.lastPercent = lastPercent
        self.nextPercent = nextPercent
    }
}
