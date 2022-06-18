//
//  CategoryModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/17.
//

import Foundation
import RxSwift
import RxRelay

protocol CategoryModelProtocol {
    var incomeCategoryData: Observable<[CategoryData]> { get }
    var expenseCategoryData: Observable<[CategoryData]> { get }
    func loadCategoryData(userId: String?)
    func setIncomeCategoryData(userId: String, data: CategoryData)
    func setExpenseCategoryData(userId: String, data: CategoryData)
    func deleteIncomeCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData])
    func deleteExpenseCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData])
}

final class CategoryModel: CategoryModelProtocol {
    private let repository: CategoryDataRepositoryProtocol
    private let incomeCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let expenseCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])

    init(repository: CategoryDataRepositoryProtocol = CategoryDataRepository()) {
        self.repository = repository
    }

    var incomeCategoryData: Observable<[CategoryData]> {
        incomeCategoryDataRelay.asObservable()
    }

    var expenseCategoryData: Observable<[CategoryData]> {
        expenseCategoryDataRelay.asObservable()
    }

    func loadCategoryData(userId: String?) {
        guard let userId = userId else {
            incomeCategoryDataRelay.accept([])
            expenseCategoryDataRelay.accept([])
            return
        }
        repository.loadCategoryData(userId: userId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success((let incomeCategoryData, let expenseCategoryData)):
                strongSelf.incomeCategoryDataRelay.accept(incomeCategoryData)
                strongSelf.expenseCategoryDataRelay.accept(expenseCategoryData)
            case .failure(let error):
                // TODO: エラー処理を追加
                break
            }
        }
    }

    func setIncomeCategoryData(userId: String, data: CategoryData) {
        repository.setIncomeCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                // TODO: エラー処理を追加
            } else {
                var incomeCategoryData = strongSelf.incomeCategoryDataRelay.value
                incomeCategoryData.append(data)
                strongSelf.incomeCategoryDataRelay.accept(incomeCategoryData)
            }
        }
    }

    func setExpenseCategoryData(userId: String, data: CategoryData) {
        repository.setExpenseCategoryData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                // TODO: エラー処理を追加
            } else {
                var expenseCategoryData = strongSelf.expenseCategoryDataRelay.value
                expenseCategoryData.append(data)
                strongSelf.expenseCategoryDataRelay.accept(expenseCategoryData)
            }
        }
    }

    func deleteIncomeCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData]) {
        repository.deleteIncomeCategoryData(userId: userId, deleteData: deleteData, data: data) { error in
            if let error = error {
                // TODO: エラー処理を追加
            }
        }
    }

    func deleteExpenseCategoryData(userId: String, deleteData: CategoryData, data: [CategoryData]) {
        repository.deleteExpenseCategoryData(userId: userId, deleteData: deleteData, data: data) { error in
            if let error = error {
                // TODO: エラー処理を追加
            }
        }
    }
}
