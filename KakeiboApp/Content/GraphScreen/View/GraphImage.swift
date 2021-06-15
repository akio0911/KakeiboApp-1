//
//  GraphImage.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/11.
//

import UIKit

struct GraphImage {
    
    func drawLine(radius: CGFloat, view: UIImageView, categoryGraphArray: [CategoryGraphInfo]) -> UIImage {
        let center = CGPoint(x: view.center.x, y: view.center.y - radius / 2)
        // イメージ処理の開始
        let size = CGSize(width: view.bounds.width, height: view.bounds.width)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        for category in categoryGraphArray {
            // 円弧のパスを作る
            let arcPath = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: category.startAngle,
                                       endAngle: category.endAngle,
                                       clockwise: true)
            arcPath.addLine(to: center)
            arcPath.close()
            category.color.setFill()
            arcPath.fill()
        }
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージビュー処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
}
