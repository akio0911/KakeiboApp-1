//
//  TableViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct TableViewHeaderData {
    let stringDate: String // 日付
    let stringTotalBalance: String // totalの収支
    let totalBalanceColorName: String // 収支textの色

    init(date: Date, totalBalance: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY年MM月dd日"
        let stringDate =
            dateFormatter.string(from: date)
        self.stringDate = stringDate
        let stringTotalBalance =
            String.localizedStringWithFormat("%d", totalBalance) + "円"
        self.stringTotalBalance = stringTotalBalance
        let totalBalanceColorName = totalBalance >= 0 ?
            CalendarColor.CeladonBlue.rawValue : CalendarColor.OrangeRedCrayola.rawValue
        self.totalBalanceColorName = totalBalanceColorName
    }
}

struct TableViewCellData {
    let stringCategory: String // カテゴリー
    let imageName: String // 収支imageName
    let stringBalance: String // 収支
    let memo: String // メモ

    init(category: Category, balance: Balance, memo: String) {
        stringCategory = category.name
        if balance.expense != 0 {
            imageName = ImageName.Expense.rawValue
            stringBalance =
                String.localizedStringWithFormat("%d", balance.expense) + "円"
        } else {
            imageName = ImageName.Income.rawValue
            stringBalance =
                String.localizedStringWithFormat("%d", balance.income) + "円"
        }
        self.memo = memo
    }
}

// MARK: - extension Category
extension Category {
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

// MARK: - ImageName
enum ImageName: String {
    case Income
    case Expense
}
