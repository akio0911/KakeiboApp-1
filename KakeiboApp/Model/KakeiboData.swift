//
//  KakeiboData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct KakeiboData {
    let date: Date //　日付
    let category: Category // カテゴリー
    let balance: Balance // 収支
    let memo: String //　メモ
}

enum Balance {
    case income(Int)
    case expense(Int)
}

enum Category: String, CaseIterable {
    case consumption = "飲食費"
    case life = "生活費"
    case miscellaneous = "雑費"
    case transpotation = "交通費"
    case medical = "医療費"
    case communication = "通信費"
    case vehicleFee = "車両費"
    case entertainment = "交際費"
    case other = "その他"
}
