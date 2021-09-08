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

    init(category: Category, totalBalance: Int) {
        stringCategory = category.rawValue
        stringTotalBalance =
            String.localizedStringWithFormat("%d", totalBalance) + "円"
    }
}
