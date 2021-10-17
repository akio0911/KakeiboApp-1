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
    func addIncomeCategoryData(addData: CategoryData)
    func addExpenseCategoryData(addData: CategoryData)
    func editIncomeCategoryData(editData: CategoryData)
    func editExpenseCategoryData(editData: CategoryData)
}

final class CategoryModel: CategoryModelProtocol {

    private let repository: CategoryDataRepositoryProtocol
    private let incomeCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let expenseCategoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])

    init(repository: CategoryDataRepositoryProtocol = CategoryDataRepository()) {
        self.repository = repository
        let incomeCategoryData = repository.loadIncomeCategoryData()
        let expenseCategoryData = repository.loadExpenseCategoryData()
        incomeCategoryDataRelay.accept(incomeCategoryData)
        expenseCategoryDataRelay.accept(expenseCategoryData)
    }

    var incomeCategoryData: Observable<[CategoryData]> {
        incomeCategoryDataRelay.asObservable()
    }

    var expenseCategoryData: Observable<[CategoryData]> {
        expenseCategoryDataRelay.asObservable()
    }

    func addIncomeCategoryData(addData: CategoryData) {
        var incomeCategoryData = incomeCategoryDataRelay.value
        incomeCategoryData.append(addData)
        repository.saveIncomeCategoryData(data: incomeCategoryData)
        incomeCategoryDataRelay.accept(incomeCategoryData)
    }

    func addExpenseCategoryData(addData: CategoryData) {
        var expenseCategoryData = expenseCategoryDataRelay.value
        expenseCategoryData.append(addData)
        repository.saveExpenseCategoryData(data: expenseCategoryData)
        expenseCategoryDataRelay.accept(expenseCategoryData)
    }

    func editIncomeCategoryData(editData: CategoryData) {
        var incomeCategoryData = incomeCategoryDataRelay.value
        let index = incomeCategoryData.firstIndex { $0.id == editData.id }
        if let index = index {
            // idが一致して、indexを取得できた場合
            incomeCategoryData[index] = editData
            repository.saveIncomeCategoryData(data: incomeCategoryData)
            incomeCategoryDataRelay.accept(incomeCategoryData)
        } else {
            // idが一致せず、indexを取得できなかった場合
            incomeCategoryData.append(editData)
            repository.saveIncomeCategoryData(data: incomeCategoryData)
            incomeCategoryDataRelay.accept(incomeCategoryData)
        }
    }

    func editExpenseCategoryData(editData: CategoryData) {
        var expenseCategoryData = expenseCategoryDataRelay.value
        let index = expenseCategoryData.firstIndex { $0.id == editData.id }
        if let index = index {
            // idが一致して、indexを取得できた場合
            expenseCategoryData[index] = editData
            repository.saveExpenseCategoryData(data: expenseCategoryData)
            expenseCategoryDataRelay.accept(expenseCategoryData)
        } else {
            // idが一致せず、indexを取得できなかった場合
            expenseCategoryData.append(editData)
            repository.saveExpenseCategoryData(data: expenseCategoryData)
            expenseCategoryDataRelay.accept(expenseCategoryData)
        }
    }
}
