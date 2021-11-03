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
    func loadIncomeCategoryDataArray(userId: String?)
    func loadExpenseCategoryDataArray(userId: String?)
    func setIncomeCategoryData(userId: String?, data: CategoryData)
    func setExpenseCategoryData(userId: String?, data: CategoryData)
    func deleteIncomeCategoryData(userId: String?, data: CategoryData)
    func deleteExpenseCategoryData(userId: String?, data: CategoryData)
    func setIncomeCategoryDataArray(userId: String?, data: [CategoryData])
    func setExpenseCategoryDataArray(userId: String?, data: [CategoryData])
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

    // TODO: userIdがない場合の処理(アラート)
    func loadIncomeCategoryDataArray(userId: String?) {
        guard let userId = userId else {
            print("💣💣💣")
            incomeCategoryDataRelay.accept([])
            return
        }
        repository.loadIncomeCategoryData(userId: userId) { [weak self] categoryDataArray in
            print("💣")
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
    }

    // TODO: userIdがない場合の処理(アラート)
    func loadExpenseCategoryDataArray(userId: String?) {
        guard let userId = userId else {
            expenseCategoryDataRelay.accept([])
            return
        }
        repository.loadExpenseCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }

    // TODO: userIdがない場合の処理(アラート)
    func setIncomeCategoryDataArray(userId: String?, data: [CategoryData]) {
        guard let userId = userId else { return }
        repository.setExpenseCategoryDataArray(userId: userId, data: data)
        incomeCategoryDataRelay.accept(data)
    }

    // TODO: userIdがない場合の処理(アラート)
    func setExpenseCategoryDataArray(userId: String?, data: [CategoryData]) {
        guard let userId = userId else { return }
        repository.setExpenseCategoryDataArray(userId: userId, data: data)
        expenseCategoryDataRelay.accept(data)
    }

    // TODO: userIdがない場合の処理(アラート)
    func setIncomeCategoryData(userId: String?, data: CategoryData) {
        guard let userId = userId else { return }
        repository.setIncomeCategoryData(userId: userId, data: data)
        repository.loadIncomeCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.incomeCategoryDataRelay.accept(categoryDataArray)
        }
    }

    // TODO: userIdがない場合の処理(アラート)
    func setExpenseCategoryData(userId: String?, data: CategoryData) {
        guard let userId = userId else { return }
        repository.setExpenseCategoryData(userId: userId, data: data)
        repository.loadExpenseCategoryData(userId: userId) { [weak self] categoryDataArray in
            guard let strongSelf = self else { return }
            strongSelf.expenseCategoryDataRelay.accept(categoryDataArray)
        }
    }

    // TODO: userIdがない場合の処理(アラート)
    func deleteIncomeCategoryData(userId: String?, data: CategoryData) {
        guard let userId = userId else { return }
        repository.deleteIncomeCategoryData(userId: userId, data: data)
    }

    // TODO: userIdがない場合の処理(アラート)
    func deleteExpenseCategoryData(userId: String?, data: CategoryData) {
        guard let userId = userId else { return }
        repository.deleteExpenseCategoryData(userId: userId, data: data)
    }
}
