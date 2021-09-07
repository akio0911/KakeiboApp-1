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

    convenience init(date: Date, category: Category, balance: Balance, memo: String) {
        self.init()
        self.date = date
        self.category = category
        self.balance = balance
        self.memo = memo
    }
}

final class Balance: Object {
    @Persisted var income: Int = 0
    @Persisted var expense: Int = 0

    convenience init(income: Int = 0, expense: Int = 0) {
        self.init()
        self.income = income
        self.expense = expense
    }
}

// TODO: Categoryをここで実装する。stringやcolorは使用するViewModelでextensionとして実装し、ここでは書かない。
enum Category: String, PersistableEnum {
    case consumption
    case life
    case miscellaneous
    case transpotation
    case medical
    case communication
    case vehicleFee
    case entertainment
    case other
}
