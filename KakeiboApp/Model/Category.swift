//
//  Category.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/11.
//

import Foundation

enum Category: CaseIterable {
    case consumption
    case life
    case miscellaneous
    case transpotation
    case medical
    case communication
    case vehicleFee
    case entertainment
    case other
    
    var name: String {
        switch self {
        case .consumption: return "飲食費"
        case .life: return "生活費"
        case .miscellaneous: return "雑費"
        case .transpotation: return "交通費"
        case .medical: return "医療費"
        case .communication: return "通信費"
        case .vehicleFee: return "車両費"
        case .entertainment: return "交際費"
        case .other: return "その他"
        }
    }
}
