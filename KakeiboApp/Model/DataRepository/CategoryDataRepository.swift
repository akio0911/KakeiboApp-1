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

    func loadIncomeCategoryData() -> [CategoryData] {
//        userDefaults.removeObject(forKey: incomeCategoryDataKey)
        guard let data = userDefaults.data(forKey: incomeCategoryDataKey) else {
            saveIncomeCategoryData(data: incomeCategoryArray)
            return incomeCategoryArray
        }
        guard let incomeCategoryDataArray =
                try? PropertyListDecoder().decode(Array<CategoryData>.self, from: data) else { return incomeCategoryArray }
        print("💣gggg")
        print(UIColor(red: 100, green: 100, blue: 100, alpha: 1))
        print(incomeCategoryDataArray)
        return incomeCategoryDataArray
    }

    func loadExpenseCategoryData() -> [CategoryData] {
//        userDefaults.removeObject(forKey: expenseCategoryDataKey)
        guard let data = userDefaults.data(forKey: expenseCategoryDataKey) else {
            saveExpenseCategoryData(data: expenseCategoryArray)
            return expenseCategoryArray
        }
        print("💣gggg")
        print(UIColor(red: 100, green: 100, blue: 100, alpha: 1))
        print("💣")
        print(data)
        guard let expenseCategoryDataArray =
                try? PropertyListDecoder().decode(Array<CategoryData>.self, from: data) else { return expenseCategoryArray }
        print("💣")
        print(expenseCategoryDataArray)
        return expenseCategoryDataArray
    }

    func saveIncomeCategoryData(data: [CategoryData]) {
        let data = try? PropertyListEncoder().encode(data)
        userDefaults.set(data, forKey: incomeCategoryDataKey)
    }

    func saveExpenseCategoryData(data: [CategoryData]) {
        let data = try? PropertyListEncoder().encode(data)
        userDefaults.set(data, forKey: expenseCategoryDataKey)
    }

    private let incomeCategoryArray: [CategoryData] = [
        CategoryData(
            id: UUID().uuidString,
            name: "給料",
            color: UIColor(red: 219, green: 83, blue: 117,alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "お小遣い",
            color: UIColor(red: 114, green: 158, blue: 161, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "賞与",
            color: UIColor(red: 229, green: 75, blue: 75, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "副業",
            color: UIColor(red: 236, green: 145, blue: 146, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "投資",
            color: UIColor(red: 230, green: 192, blue: 233, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "臨時収入",
            color: UIColor(red: 95, green: 80, blue: 170, alpha: 1)
        )
    ]

    private let expenseCategoryArray: [CategoryData] = [
        CategoryData(
            id: UUID().uuidString,
            name: "飲食費",
            color: UIColor(red: 219, green: 83, blue: 117,alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "生活費",
            color: UIColor(red: 114, green: 158, blue: 161, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "雑費",
            color: UIColor(red: 229, green: 75, blue: 75, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "交通費",
            color: UIColor(red: 236, green: 145, blue: 146, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "医療費",
            color: UIColor(red: 230, green: 192, blue: 233, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "通信費",
            color: UIColor(red: 95, green: 80, blue: 170, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "車両費",
            color: UIColor(red: 180, green: 101, blue: 111, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "交際費",
            color: UIColor(red: 181, green: 189, blue: 137, alpha: 1)
        ),
        CategoryData(
            id: UUID().uuidString,
            name: "その他",
            color: UIColor(red: 223, green: 190, blue: 153, alpha: 1)
        )
    ]
}
