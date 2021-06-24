//
//  IncomeAndExpenditure.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/30.
//

import Foundation

struct IncomeAndExpenditure: Equatable {
    
    let date: Date //　収支の日付
    let category: String // 収支の分類
    let expenses: Int // 収支の費用
    let memo: String // 収支についてのメモ

    init(date: Date, category: String, expenses: Int, memo: String) {
        self.date = date
        self.category = category
        self.expenses = expenses
        self.memo = memo
    }

    // userDafaultの保存内容からインスタンスを作成するイニシャライザ
    init(from dictionary: [String: Any]) {
        // swiftlint:disable force_cast
        self.date = dictionary["date"] as! Date
        self.category = dictionary["category"] as! String
        self.expenses = dictionary["expenses"] as! Int
        self.memo = dictionary["memo"] as! String
        // swiftlint:enable force_cast
    }
}
