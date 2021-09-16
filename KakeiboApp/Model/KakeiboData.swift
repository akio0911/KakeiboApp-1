//
//  KakeiboData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct KakeiboData: Codable, Equatable {
    static func == (lhs: KakeiboData, rhs: KakeiboData) -> Bool {
        lhs.date == rhs.date
            && lhs.category == rhs.category
            && lhs.balance == rhs.balance
            && lhs.memo == rhs.memo
    }
    
    var instantiateTime =
        DateUtility.stringFromDate(date: Date(), format: "YYYY年MM月dd日 HH:mm:ss")
    let date: Date //　日付
    let category: Category // カテゴリー
    let balance: Balance // 収支
    let memo: String //　メモ
}

enum Balance: Equatable {
    case income(Int)
    case expense(Int)

    var fetchValueSigned: Int {
        switch self {
        case .income(let income):
            return income
        case .expense(let expense):
            return -expense
        }
    }

    var fetchValue: Int {
        switch self {
        case .income(let income):
            return income
        case .expense(let expense):
            return expense
        }
    }
}

enum Category: Equatable {
    case income(Income)
    case expense(Expense)

    enum Income: String, CaseIterable, Codable {
        case salary = "給料"
        case allowance = "お小遣い"
        case bonus = "賞与"
        case sideJob = "副業"
        case investment = "投資"
        case extraordinaryIncome = "臨時収入"
    }

    enum Expense: String, CaseIterable, Codable {
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
}

extension Balance: Codable {
    enum CodingKeys: String, CodingKey {
        case income
        case expense
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(Int.self, forKey: .income) {
            self = .income(value)
        } else if let value = try container.decodeIfPresent(Int.self, forKey: .expense) {
            self = .expense(value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath, debugDescription: "Unknown case"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .income(let value):
            try container.encode(value, forKey: .income)
        case .expense(let value):
            try container.encode(value, forKey: .expense)
        }
    }
}

extension Category: Codable {
    enum CodingKeys: String, CodingKey {
            case income
            case expense
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let incomeCategory = try container.decodeIfPresent(Income.self, forKey: .income) {
            self = .income(incomeCategory)
        } else if let expenseCategory = try container.decodeIfPresent(Expense.self, forKey: .expense) {
            self = .expense(expenseCategory)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath, debugDescription: "Unknown case"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .income(let incomeCategory):
            try container.encode(incomeCategory, forKey: .income)
        case .expense(let expenseCategory):
            try container.encode(expenseCategory, forKey: .expense)
        }
    }
}
