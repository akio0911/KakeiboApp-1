//
//  CategoryDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

protocol CategoryDataRepositoryProtocol {
    func loadIncomeCategoryData() -> [CategoryData]
    func loadExpenseCategoryData() -> [CategoryData]
    func saveIncomeCategoryData(data: [CategoryData])
    func saveExpenseCategoryData(data: [CategoryData])
}

final class CategoryDataRepository: CategoryDataRepositoryProtocol {

    private let userDefaults = UserDefaults.standard
    private let incomeCategoryDataKey = "incomeCategoryData"
    private let expenseCategoryDataKey = "expenseCategoryData"

    // 収入カテゴリーを読み込む
    func loadIncomeCategoryData() -> [CategoryData] {
        // 保存データがない場合
        guard let data = userDefaults.data(forKey: incomeCategoryDataKey) else {
            // 初期の収入カテゴリーを保存
            saveIncomeCategoryData(data: incomeCategoryArray)
            // 初期の収入カテゴリーを返す
            return incomeCategoryArray
        }

        // 保存データがあった場合
        guard let incomeCategoryDataArray =
                try? PropertyListDecoder().decode(Array<CategoryData>.self, from: data) else { return incomeCategoryArray }
        return incomeCategoryDataArray
    }

    // 支出カテゴリーを読み込む
    func loadExpenseCategoryData() -> [CategoryData] {
        // 保存データがない場合
        guard let data = userDefaults.data(forKey: expenseCategoryDataKey) else {
            // 初期の支出カテゴリーを保存
            saveExpenseCategoryData(data: expenseCategoryArray)
            // 初期の支出カテゴリーを返す
            return expenseCategoryArray
        }

        // 保存データがあった場合
        guard let expenseCategoryDataArray =
                try? PropertyListDecoder().decode(Array<CategoryData>.self, from: data) else { return expenseCategoryArray }
        return expenseCategoryDataArray
    }

    // 収入カテゴリーを保存
    func saveIncomeCategoryData(data: [CategoryData]) {
        let data = try? PropertyListEncoder().encode(data)
        userDefaults.set(data, forKey: incomeCategoryDataKey)
    }

    // 支出カテゴリーを保存
    func saveExpenseCategoryData(data: [CategoryData]) {
        let data = try? PropertyListEncoder().encode(data)
        userDefaults.set(data, forKey: expenseCategoryDataKey)
    }

    // 初期の収入カテゴリー
    private let incomeCategoryArray: [CategoryData] = [
        CategoryData(
            id: UUID().uuidString,
            name: "給料",
            color: UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255,alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "お小遣い",
            color: UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "賞与",
            color: UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "副業",
            color: UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "投資",
            color: UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "臨時収入",
            color: UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1)
        )
    ]

    // 初期の支出カテゴリー
    private let expenseCategoryArray: [CategoryData] = [
        CategoryData(
            id: UUID().uuidString,
            name: "飲食費",
            color: UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "生活費",
            color: UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "雑費",
            color: UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "交通費",
            color: UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "医療費",
            color: UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "通信費",
            color: UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "車両費",
            color: UIColor(red: 180 / 255, green: 101 / 255, blue: 111 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "交際費",
            color: UIColor(red: 181 / 255, green: 189 / 255, blue: 137 / 255, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "その他",
            color: UIColor(red: 223 / 255, green: 190 / 255, blue: 153 / 255, alpha: 1)
        )
    ]
}
