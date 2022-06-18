//
//  CategoryDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol CategoryDataRepositoryProtocol {
    func loadCategoryData(userId: String, completion: @escaping (Result<(incomeCategoryData:[CategoryData], expenseCategoryData: [CategoryData]), Error>) -> Void)
    func setIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping (Error?) -> Void)
    func setExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping (Error?) -> Void)
    func deleteIncomeCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData], completion: @escaping (Error?) -> Void)
    func deleteExpenseCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData], completion: @escaping (Error?) -> Void)
}

final class CategoryDataRepository: CategoryDataRepositoryProtocol {
    private let firstCollectionName = "users"
    private let incomeCategoryName = "incomeCategoryData"
    private let expenseCategoryName = "expenseCategoryData"

    private let db: Firestore // swiftlint:disable:this identifier_name

    init() {
        let setting = FirestoreSettings()
        Firestore.firestore().settings = setting
        db = Firestore.firestore()
    }

    func loadCategoryData(userId: String, completion: @escaping (Result<(incomeCategoryData: [CategoryData], expenseCategoryData: [CategoryData]), Error>) -> Void) {
        loadIncomeCategoryData(userId: userId) { [weak self] result in
            switch result {
            case .success(let incomeCategoryData):
                self?.loadExpenseCategoryData(userId: userId) { result in
                    switch result {
                    case .success(let expenseCategoryData):
                        completion(.success((incomeCategoryData: incomeCategoryData, expenseCategoryData: expenseCategoryData)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 収入カテゴリーを読み込む
    func loadIncomeCategoryData(userId: String, completion: @escaping (Result<[CategoryData], Error>) -> Void) {
        db.collection(firstCollectionName)
            .document(userId)
            .collection(incomeCategoryName)
            .order(by: "displayOrder")
            .getDocuments { [weak self] querySnapshot, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    completion(.failure(error))
                } else {
                    // 読み込みに成功
                    if let documents = querySnapshot?.documents {
                        if documents.isEmpty {
                            // 保存データ配列が空の時
                            let initialIncomeCategory = strongSelf.createInitialIncomeCategory()
                            strongSelf.setIncomeCategoryDataArray(userId: userId, data: initialIncomeCategory) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(initialIncomeCategory))
                                }
                            }
                            return
                        }
                        // 保存データがある
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
                                print("----Error decoding item: \(error.localizedDescription)----")
                            }
                        }
                        completion(.success(categoryArray))
                    }
                }
            }
    }

    // 支出カテゴリーを読み込む
    func loadExpenseCategoryData(userId: String, completion: @escaping (Result<[CategoryData], Error>) -> Void) {
        db.collection(firstCollectionName)
            .document(userId)
            .collection(expenseCategoryName)
            .order(by: "displayOrder")
            .getDocuments { [weak self] querySnapshot, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    completion(.failure(error))
                } else {
                    // 読み込みに成功
                    if let documents = querySnapshot?.documents {
                        if documents.isEmpty {
                            // 保存データ配列が空の時
                            let initialExpenseCategory = strongSelf.createInitialExpenseCategory()
                            strongSelf.setExpenseCategoryDataArray(userId: userId, data: initialExpenseCategory) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(initialExpenseCategory))
                                }
                            }
                            return
                        }
                        // 保存データがある
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
                                print("----Error decoding item: \(error.localizedDescription)----")
                            }
                        }
                        completion(.success(categoryArray))
                    }
                }
            }
    }

    // 収入カテゴリー配列を保存
    private func setIncomeCategoryDataArray(userId: String, data: [CategoryData], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        for categoryData in data {
            do {
                let categoryDataIdRef = db.collection(firstCollectionName)
                    .document(userId)
                    .collection(incomeCategoryName)
                    .document(categoryData.id)
                try batch.setData(from: categoryData, forDocument: categoryDataIdRef)
            } catch let error {
                completion(error)
                break
            }
        }
        batch.commit() { error in
            completion(error)
        }
    }

    // 支出カテゴリー配列を保存
    private func setExpenseCategoryDataArray(userId: String, data: [CategoryData], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        for categoryData in data {
            do {
                let categoryDataIdRef = db.collection(firstCollectionName)
                    .document(userId)
                    .collection(expenseCategoryName)
                    .document(categoryData.id)
                try batch.setData(from: categoryData, forDocument: categoryDataIdRef)
            } catch let error {
                completion(error)
                break
            }
        }
        batch.commit() { error in
            completion(error)
        }
    }

    func setIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping (Error?) -> Void) {
        do {
            // 作成または上書き
            let ref = db.collection(firstCollectionName)
                .document(userId)
                .collection(incomeCategoryName)
                .document(data.id)
            try ref.setData(from: data)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

    func setExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping (Error?) -> Void) {
        do {
            // 作成または上書き
            let ref = db.collection(firstCollectionName)
                .document(userId)
                .collection(expenseCategoryName)
                .document(data.id)
            try ref.setData(from: data)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

    func deleteIncomeCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let deleteDataRef = db.collection(firstCollectionName)
            .document(userId)
            .collection(incomeCategoryName)
            .document(deleteData.id)
        batch.deleteDocument(deleteDataRef)
        for categoryData in data {
            do {
                let categoryDataIdRef = db.collection(firstCollectionName)
                    .document(userId)
                    .collection(incomeCategoryName)
                    .document(categoryData.id)
                try batch.setData(from: categoryData, forDocument: categoryDataIdRef)
            } catch let error {
                completion(error)
                break
            }
        }
        batch.commit() { error in
            completion(error)
        }
    }

    func deleteExpenseCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        let deleteDataRef = db.collection(firstCollectionName)
            .document(userId)
            .collection(expenseCategoryName)
            .document(deleteData.id)
        batch.deleteDocument(deleteDataRef)
        for categoryData in data {
            do {
                let categoryDataIdRef = db.collection(firstCollectionName)
                    .document(userId)
                    .collection(incomeCategoryName)
                    .document(categoryData.id)
                try batch.setData(from: categoryData, forDocument: categoryDataIdRef)
            } catch let error {
                completion(error)
                break
            }
        }
        batch.commit() { error in
            completion(error)
        }
    }

    private func createInitialIncomeCategory() -> [CategoryData] {
        let incomeCategory: [(String, UIColor)] = [
            ("給料", UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1)),
            ("お小遣い", UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)),
            ("賞与", UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)),
            ("副業", UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)),
            ("投資", UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)),
            ("臨時収入", UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1))
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
            ("飲食費", UIColor(red: 219 / 255, green: 83 / 255, blue: 117 / 255, alpha: 1)),
            ("生活費", UIColor(red: 114 / 255, green: 158 / 255, blue: 161 / 255, alpha: 1)),
            ("雑費", UIColor(red: 229 / 255, green: 75 / 255, blue: 75 / 255, alpha: 1)),
            ("交通費", UIColor(red: 236 / 255, green: 145 / 255, blue: 146 / 255, alpha: 1)),
            ("医療費", UIColor(red: 230 / 255, green: 192 / 255, blue: 233 / 255, alpha: 1)),
            ("通信費", UIColor(red: 95 / 255, green: 80 / 255, blue: 170 / 255, alpha: 1)),
            ("車両費", UIColor(red: 180 / 255, green: 101 / 255, blue: 111 / 255, alpha: 1)),
            ("交際費", UIColor(red: 181 / 255, green: 189 / 255, blue: 137 / 255, alpha: 1)),
            ("その他", UIColor(red: 223 / 255, green: 190 / 255, blue: 153 / 255, alpha: 1))
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
