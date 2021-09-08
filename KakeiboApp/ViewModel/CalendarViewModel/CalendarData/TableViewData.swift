//
//  TableViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct HeaderDateKakeiboData {
    let stringDate: String // 日付
    let stringTotalBalance: String // totalの収支
    let totalBalanceColorName: String // 収支textの色

    init(date: Date, totalBalance: Int) {
        let stringDate = DateUtility.stringFromDate(date: date, format: "YYYY年MM月dd日")
        self.stringDate = stringDate
        let stringTotalBalance =
            String.localizedStringWithFormat("%d", totalBalance) + "円"
        self.stringTotalBalance = stringTotalBalance
        let totalBalanceColorName = totalBalance >= 0 ?
            CalendarColorName.CeladonBlue.rawValue : CalendarColorName.OrangeRedCrayola.rawValue
        self.totalBalanceColorName = totalBalanceColorName
    }
}

struct CellDateKakeiboData {
    let stringCategory: String // カテゴリー
    let imageName: String // 収支imageName
    let stringBalance: String // 収支
    let memo: String // メモ

    init(category: Category, balance: Balance, memo: String) {
        stringCategory = category.rawValue
        switch balance {
        case .income(let income):
            imageName = ImageName.Income.rawValue
            stringBalance = String.localizedStringWithFormat("%d", income) + "円"
        case .expense(let expense):
            imageName = ImageName.Expense.rawValue
            stringBalance = String.localizedStringWithFormat("%d", expense) + "円"
        }
        self.memo = memo
    }
}

// MARK: - ImageName
enum ImageName: String {
    case Income
    case Expense
}
