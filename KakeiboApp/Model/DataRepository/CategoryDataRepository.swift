//
//  CategoryDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

protocol CategoryDataRepositoryProtocol {
    func loadIncomeCategoryData(data: @escaping ([CategoryData]) -> Void)
    func loadExpenseCategoryData(data: @escaping ([CategoryData]) -> Void)
    func setIncomeCategoryDataArray(data: [CategoryData])
    func setExpenseCategoryDataArray(data: [CategoryData])
    func setIncomeCategoryData(data: CategoryData)
    func setExpenseCategoryData(data: CategoryData)
    func deleteIncomeCategoryData(data: CategoryData)
    func deleteExpenseCategoryData(data: CategoryData)
}

final class CategoryDataRepository: CategoryDataRepositoryProtocol {

    private let firstCollectionName = "users"
    private let incomeCategoryName = "incomeCategoryData"
    private let expenseCategoryName = "expenseCategoryData"

    private let db: Firestore

    init() {
        let setting = FirestoreSettings()
        Firestore.firestore().settings = setting
        db = Firestore.firestore()
    }

    // 収入カテゴリーを読み込む
    func loadIncomeCategoryData(data: @escaping ([CategoryData]) -> Void) {
        db.collection(firstCollectionName)
            .document(Auth.auth().currentUser!.uid)
            .collection(incomeCategoryName)
            .order(by: "displayOrder")
            .getDocuments { [weak self] querySnapshot, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    // 読み込みに失敗
                    print("💣----Error getting documents: \(error.localizedDescription)----")
                } else {
                    // 読み込みに成功
                    if let documents = querySnapshot?.documents {
                        // 保存データがある
                        print("💣保存データがある")
                        print("💣documents: \(documents)")
                        if documents.isEmpty {
                            // 保存データ配列が空の時
                            let initialIncomeCategory = strongSelf.createInitialIncomeCategory()
                            strongSelf.setIncomeCategoryDataArray(data: initialIncomeCategory)
                            data(initialIncomeCategory)
                            print("💣💣💣")
                            return
                        }
                        var categoryArray: [CategoryData] = []
                        documents.forEach { document in
                            let result = Result {
                                try document.data(as: CategoryData.self)
                            }
                            switch result {
                            case .success(let data):
                                print("💣変換成功")
                                // CategoryData型に変換成功
                                if let data = data {
                                    categoryArray.append(data)
                                }
                            case .failure(let error):
                                print("💣変換失敗")
                                // CategoryData型に変換失敗
                                print("----Error decoding item: \(error)----")
                            }
                        }
                        data(categoryArray)
                    }
                }
            }
    }

    // 支出カテゴリーを読み込む
    func loadExpenseCategoryData(data: @escaping ([CategoryData]) -> Void) {
        db.collection(firstCollectionName)
            .document(Auth.auth().currentUser!.uid)
            .collection(expenseCategoryName)
            .order(by: "displayOrder")
            .getDocuments { [weak self] querySnapshot, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    // 読み込みに失敗
                    print("----Error getting documents: \(error)----")
                } else {
                    // 読み込みに成功
                    if let documents = querySnapshot?.documents {
                        // 保存データがある
                        if documents.isEmpty {
                            // 保存データ配列が空の時
                            let initialExpenseCategory = strongSelf.createInitialExpenseCategory()
                            strongSelf.setExpenseCategoryDataArray(data: initialExpenseCategory)
                            data(initialExpenseCategory)
                            return
                        }
                        var categoryArray: [CategoryData] = []
                        documents.forEach { document in
                            let result = Result {
                                try document.data(as: CategoryData.self)
                            }
                            switch result {
                            case .success(let data):
                                // CategoryData型に変換成功
                                if let data = data {
                                    categoryArray.append(data)
                                }
                            case .failure(let error):
                                // CategoryData型に変換失敗
                                print("----Error decoding item: \(error)----")
                            }
                        }
                        data(categoryArray)
                    }
                }
            }
    }

    // 収入カテゴリー配列を保存
    func setIncomeCategoryDataArray(data: [CategoryData]) {
        data.forEach { categoryData in
            do {
                let ref = db.collection(firstCollectionName)
                    .document(Auth.auth().currentUser!.uid)
                    .collection(incomeCategoryName)
                    .document(categoryData.id)
                try ref.setData(from: categoryData)
            } catch let error {
                print("----Error writing categoryData to Firestore: \(error)----")
            }
        }
    }

    // 支出カテゴリー配列を保存
    func setExpenseCategoryDataArray(data: [CategoryData]) {
        data.forEach { categoryData in
            do {
                let ref = db.collection(firstCollectionName)
                    .document(Auth.auth().currentUser!.uid)
                    .collection(expenseCategoryName)
                    .document(categoryData.id)
                try ref.setData(from: categoryData)
            } catch let error {
                print("----Error writing categoryData to Firestore: \(error)----")
            }
        }
    }

    func setIncomeCategoryData(data: CategoryData) {
        do {
            // 作成または上書き
            let ref = db.collection(firstCollectionName)
                .document(Auth.auth().currentUser!.uid)
                .collection(incomeCategoryName)
                .document(data.id)
            try ref.setData(from: data)
        } catch let error {
            print("Error writing categoryData to Firestore: \(error)")
        }
    }

    func setExpenseCategoryData(data: CategoryData) {
        do {
            // 作成または上書き
            let ref = db.collection(firstCollectionName)
                .document(Auth.auth().currentUser!.uid)
                .collection(expenseCategoryName)
                .document(data.id)
            print("💣data.id: \(data.id)")
            try ref.setData(from: data)
        } catch let error {
            print("Error writing categoryData to Firestore: \(error)")
        }
    }

    func deleteIncomeCategoryData(data: CategoryData) {
        db.collection(firstCollectionName)
            .document(Auth.auth().currentUser!.uid)
            .collection(incomeCategoryName)
            .document(data.id)
            .delete { error in
                if let error = error {
                    print("Error delete categoryData to Firestore: \(error)")
                }
            }
    }

    func deleteExpenseCategoryData(data: CategoryData) {
        db.collection(firstCollectionName)
            .document(Auth.auth().currentUser!.uid)
            .collection(expenseCategoryName)
            .document(data.id)
            .delete { error in
                if let error = error {
                    print("Error delete categoryData to Firestore: \(error)")
                }
            }
    }

    private func createInitialIncomeCategory() -> [CategoryData] {
        let incomeCategory: [(String, UIColor)] = [
            ("給料", UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255,alpha: 1)),
            ("お小遣い",UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)),
            ("賞与",UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)),
            ("副業",UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)),
            ("投資",UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)),
            ("臨時収入",UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1))
        ]
        return incomeCategory.enumerated().map {
            CategoryData(
                id: UUID().uuidString,
                displayOrder: $0.offset,
                name: $0.element.0,
                color: $0.element.1
            )
        }
    }



    private func createInitialExpenseCategory() -> [CategoryData] {
        let expenseCategory: [(String, UIColor)] = [
            ("飲食費",UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1)),
            ("生活費",UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)),
            ("雑費",UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)),
            ("交通費",UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)),
            ("医療費",UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)),
            ("通信費",UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1)),
            ("車両費",UIColor(red: 180 / 255, green: 101 / 255, blue: 111 / 255, alpha: 1)),
            ("交際費",UIColor(red: 181 / 255, green: 189 / 255, blue: 137 / 255, alpha: 1)),
            ("その他",UIColor(red: 223 / 255, green: 190 / 255, blue: 153 / 255, alpha: 1))
        ]
        return expenseCategory.enumerated().map {
            CategoryData(
                id: UUID().uuidString,
                displayOrder: $0.offset,
                name: $0.element.0,
                color: $0.element.1
            )
        }
    }
}
