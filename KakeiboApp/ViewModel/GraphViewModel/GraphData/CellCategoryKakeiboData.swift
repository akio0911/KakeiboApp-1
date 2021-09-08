//
//  CellCategoryKakeiboData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import Foundation

struct CellCategoryKakeiboData {
    let stringCategory: String
    let stringTotalBalance: String
    let viewColorName: String

    init(category: Category, totalBalance: Int) {
        stringCategory = category.rawValue
        stringTotalBalance =
            String.localizedStringWithFormat("%d", totalBalance) + "円"
        viewColorName = category.colorName
    }
}

extension Category {
    var colorName: String {
        switch self {
        case .consumption:
            return GraphColorName.CadetBlue.rawValue
        case .life:
            return GraphColorName.Blush.rawValue
        case .miscellaneous:
            return GraphColorName.ImperialRed.rawValue
        case .transpotation:
            return GraphColorName.LightCoral.rawValue
        case .medical:
            return GraphColorName.PinkLavender.rawValue
        case .communication:
            return GraphColorName.PlumpPurple.rawValue
        case .vehicleFee:
            return GraphColorName.Popstar.rawValue
        case .entertainment:
            return GraphColorName.Sage.rawValue
        case .other:
            return GraphColorName.Tan.rawValue
        }
    }
}
