//
//  Category.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/11.
//

import UIKit

enum Category: String, CaseIterable, Codable {
    case consumption = "飲食費"
    case life = "生活費"
    case miscellaneous = "雑費"
    case transpotation = "交通費"
    case medical = "医療費"
    case communication = "通信費"
    case vehicleFee = "車両費"
    case entertainment = "交際費"
    case other = "その他"

    var color: UIColor {
        switch self {
        case .consumption:
            return UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)
        case .life:
            return UIColor(red: 181 / 255, green: 189 / 255, blue: 137 / 255, alpha: 1)
        case .miscellaneous:
            return UIColor(red: 223 / 255, green: 190 / 255, blue: 153 / 255, alpha: 1)
        case .transpotation:
            return UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)
        case .medical:
            return UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1)
        case .communication:
            return UIColor(red: 180 / 255, green: 101 / 255, blue: 111 / 255, alpha: 1)
        case .vehicleFee:
            return UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)
        case .entertainment:
            return UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)
        case .other:
            return UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1)
        }
    }
}
