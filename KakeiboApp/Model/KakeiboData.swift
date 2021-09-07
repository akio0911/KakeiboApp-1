//
//  KakeiboData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation
import RealmSwift

final class KakeiboData: Object {
    @Persisted var date: Date = Date() //　日付
    @Persisted var category: Category = .consumption // カテゴリー
    @Persisted var balance: Balance? // 収支
    @Persisted var memo: String = "" //　メモ

    convenience init(stringDate: String, category: String, balance: Balance, memo: String) {
        self.init()
        self.date = DateUtility.dateFromString(stringDate: stringDate, format: "YYYY年MM月dd日")
        self.category = Category(rawValue: category) ?? .consumption
        self.balance = balance
        self.memo = memo
    }
}

final class Balance: Object {
    @Persisted var income: Int = 0
    @Persisted var expense: Int = 0

    convenience init(income: String = "0", expense: String = "0") {
        self.init()
        self.income = Int(income) ?? 0
        self.expense = Int(expense) ?? 0
    }
}

enum Category: String, PersistableEnum {
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
