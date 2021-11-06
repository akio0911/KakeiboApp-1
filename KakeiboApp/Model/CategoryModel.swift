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
    func deleteIncomeCategoryData(userId: String, data: CategoryData)
    func deleteExpenseCategoryData(userId: String, data: CategoryData)
    func setIncomeCategoryDataArray(userId: String, data: [CategoryData])
    func setExpenseCategoryDataArray(userId: String, data: [CategoryData])
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
        repository.loadIncomeCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
        repository.loadExpenseCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }

    func setIncomeCategoryDataArray(userId: String, data: [CategoryData]) {
        repository.setExpenseCategoryDataArray(userId: userId, data: data)
        incomeCategoryDataRelay.accept(data)
    }

    func setExpenseCategoryDataArray(userId: String, data: [CategoryData]) {
        repository.setExpenseCategoryDataArray(userId: userId, data: data)
        expenseCategoryDataRelay.accept(data)
    }

    func setIncomeCategoryData(userId: String, data: CategoryData) {
        repository.setIncomeCategoryData(userId: userId, data: data)
        repository.loadIncomeCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
    }

    func setExpenseCategoryData(userId: String, data: CategoryData) {
        repository.setExpenseCategoryData(userId: userId, data: data)
        repository.loadExpenseCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }
    
    func deleteIncomeCategoryData(userId: String, data: CategoryData) {
        repository.deleteIncomeCategoryData(userId: userId, data: data)
    }

    func deleteExpenseCategoryData(userId: String, data: CategoryData) {
        repository.deleteExpenseCategoryData(userId: userId, data: data)
    }
}
