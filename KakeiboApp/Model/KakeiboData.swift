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
            && lhs.categoryId == rhs.categoryId
            && lhs.balance == rhs.balance
            && lhs.memo == rhs.memo
    }

    var instantiateTime =
        DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月dd日 HH:mm:ss")
    let date: Date //　日付
    let categoryId: CategoryId // カテゴリー
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

enum CategoryId: Equatable {
    case income(String)
    case expense(String)
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

extension CategoryId: Codable {
    enum CodingKeys: String, CodingKey {
            case income
            case expense
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let incomeCategoryId = try container.decodeIfPresent(String.self, forKey: .income) {
            self = .income(incomeCategoryId)
        } else if let expenseCategoryId = try container.decodeIfPresent(String.self, forKey: .expense) {
            self = .expense(expenseCategoryId)
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
        case .income(let incomeCategoryId):
            try container.encode(incomeCategoryId, forKey: .income)
        case .expense(let expenseCategoryId):
            try container.encode(expenseCategoryId, forKey: .expense)
        }
    }
}
