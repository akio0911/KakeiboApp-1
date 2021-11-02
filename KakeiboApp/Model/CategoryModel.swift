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
    func setIncomeCategoryData(data: CategoryData)
    func setExpenseCategoryData(data: CategoryData)
    func deleteIncomeCategoryData(data: CategoryData)
    func deleteExpenseCategoryData(data: CategoryData)
    func setIncomeCategoryDataArray(data: [CategoryData])
    func setExpenseCategoryDataArray(data: [CategoryData])
}

final class CategoryModel: CategoryModelProtocol {

    private let repository: CategoryDataRepositoryProtocol
    private let incomeCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let expenseCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])

    init(repository: CategoryDataRepositoryProtocol = CategoryDataRepository()) {
        self.repository = repository
        repository.loadIncomeCategoryData { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
        repository.loadExpenseCategoryData { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }

    var incomeCategoryData: Observable<[CategoryData]> {
        incomeCategoryDataRelay.asObservable()
    }

    var expenseCategoryData: Observable<[CategoryData]> {
        expenseCategoryDataRelay.asObservable()
    }

    func setIncomeCategoryDataArray(data: [CategoryData]) {
        repository.setExpenseCategoryDataArray(data: data)
        incomeCategoryDataRelay.accept(data)
    }

    func setExpenseCategoryDataArray(data: [CategoryData]) {
        repository.setExpenseCategoryDataArray(data: data)
        expenseCategoryDataRelay.accept(data)
    }

    func setIncomeCategoryData(data: CategoryData) {
        repository.setIncomeCategoryData(data: data)
        repository.loadIncomeCategoryData { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
    }

    func setExpenseCategoryData(data: CategoryData) {
        repository.setExpenseCategoryData(data: data)
        repository.loadExpenseCategoryData { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }

    func deleteIncomeCategoryData(data: CategoryData) {
        repository.deleteIncomeCategoryData(data: data)
    }

    func deleteExpenseCategoryData(data: CategoryData) {
        repository.deleteExpenseCategoryData(data: data)
    }
}
