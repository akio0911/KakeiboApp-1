//
//  CategoryModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/17.
//

import Foundation
import RxSwift
import RxRelay

typealias CategoryModelCompletion = (Error?) -> Void

protocol CategoryModelProtocol {
    func setupData(userId: String?, completion: @escaping CategoryModelCompletion)
    func addIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion)
    func addExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion)
    func editIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion)
    func editExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion)
    func deleteIncomeCategoryData(userId: String, indexPath: IndexPath, completion: @escaping CategoryModelCompletion)
    func deleteExpenseCategoryData(userId: String, indexPath: IndexPath, completion: @escaping CategoryModelCompletion)
    var incomeCategoryDataArray: [CategoryData] { get }
    var expenseCategoryDataArray: [CategoryData] { get }
}

final class CategoryModel: CategoryModelProtocol {
    private let repository: CategoryDataRepositoryProtocol
    private(set) var incomeCategoryDataArray: [CategoryData] = []
    private(set) var expenseCategoryDataArray: [CategoryData] = []

    init(repository: CategoryDataRepositoryProtocol = CategoryDataRepository()) {
        self.repository = repository
    }

    func setupData(userId: String?, completion: @escaping CategoryModelCompletion) {
        guard let userId = userId else {
            incomeCategoryDataArray = []
            expenseCategoryDataArray = []
            completion(nil)
            return
        }
        repository.loadCategoryData(userId: userId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success((let incomeCategoryData, let expenseCategoryData)):
                strongSelf.incomeCategoryDataArray = incomeCategoryData
                strongSelf.expenseCategoryDataArray = expenseCategoryData
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func addIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion) {
        repository.setIncomeCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                strongSelf.incomeCategoryDataArray.append(data)
                completion(nil)
            }
        }
    }

    func addExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion) {
        repository.setExpenseCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                strongSelf.expenseCategoryDataArray.append(data)
                completion(nil)
            }
        }
    }

    func editIncomeCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion) {
        repository.setIncomeCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                for (index, value) in strongSelf.incomeCategoryDataArray.enumerated() where value.id == data.id {
                    strongSelf.incomeCategoryDataArray[index] = data
                }
                completion(nil)
            }
        }
    }

    func editExpenseCategoryData(userId: String, data: CategoryData, completion: @escaping CategoryModelCompletion) {
        repository.setExpenseCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                for (index, value) in strongSelf.expenseCategoryDataArray.enumerated() where value.id == data.id {
                    strongSelf.expenseCategoryDataArray[index] = data
                }
                completion(nil)
            }
        }
    }

    func deleteIncomeCategoryData(userId: String, indexPath: IndexPath, completion: @escaping CategoryModelCompletion) {
        var data = incomeCategoryDataArray
        let deleteData = data[indexPath.row]
        data.remove(at: indexPath.row)
        data.indices.forEach {
            data[$0].displayOrder = $0
        }
        repository.deleteIncomeCategoryData(userId: userId, deleteData: deleteData, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                strongSelf.incomeCategoryDataArray = data
                completion(nil)
            }
        }
    }

    func deleteExpenseCategoryData(userId: String, indexPath: IndexPath, completion: @escaping CategoryModelCompletion) {
        var data = expenseCategoryDataArray
        let deleteData = data[indexPath.row]
        data.remove(at: indexPath.row)
        data.indices.forEach {
            data[$0].displayOrder = $0
        }
        repository.deleteExpenseCategoryData(userId: userId, deleteData: deleteData, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                strongSelf.expenseCategoryDataArray = data
                completion(nil)
            }
        }
    }
}
