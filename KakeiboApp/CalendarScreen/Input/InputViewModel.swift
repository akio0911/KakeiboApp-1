//
//  InputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import RxSwift
import RxCocoa

protocol InputViewModelInput {
    func didTapSaveButton(data: KakeiboData)
    func didTapCancelButton()
    func addDate(date: Date)
    func editData(data: KakeiboData)
    func didTapNextDayButton()
    func didTapLastDayButton()
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
    var mode: InputViewModel.Mode { get }
    var date: Driver<String> { get }
    var category: Driver<String> { get }
    var segmentIndex: Driver<Int> { get }
    var balance: Driver<String> { get }
    var memo: Driver<String> { get }
    var incomeCategory: Driver<[CategoryData]> { get }
    var expenseCategory: Driver<[CategoryData]> { get }
}

protocol InputViewModelType {
    var inputs: InputViewModelInput { get }
    var outputs: InputViewModelOutput { get }
}

final class InputViewModel: InputViewModelInput, InputViewModelOutput {
    enum Event {
        case dismiss
        case presetDismissAlert(String, String)
    }

    enum Mode {
        case add(Date)
        case edit(KakeiboData)
    }

    let mode: Mode
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let eventRelay = PublishRelay<Event>()
    private var kakeiboDataArray: [KakeiboData] = []
    private let dateRelay = BehaviorRelay<String>(value: "")
    private let categoryRelay = PublishRelay<String>()
    private let segmentIndexRelay = PublishRelay<Int>()
    private let balanceRelay = PublishRelay<String>()
    private let memoRelay = PublishRelay<String>()
    private let incomeCategoryRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let expenseCategoryRelay = BehaviorRelay<[CategoryData]>(value: [])
    private var userInfo: UserInfo?

    init(kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         mode: Mode,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        self.mode = mode
        self.authType = authType
        setupBinding()
    }

    private func setupBinding() {
        authType.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                guard let strongSelf = self else { return }
                strongSelf.userInfo = userInfo
            })
            .disposed(by: disposeBag)

        kakeiboModel.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let strongSelf = self else { return }
                strongSelf.kakeiboDataArray = kakeiboDataArray
            })
            .disposed(by: disposeBag)

        categoryModel.incomeCategoryData
            .bind(to: incomeCategoryRelay)
            .disposed(by: disposeBag)

        categoryModel.expenseCategoryData
            .bind(to: expenseCategoryRelay)
            .disposed(by: disposeBag)
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    var date: Driver<String> {
        dateRelay.asDriver(onErrorDriveWith: .empty())
    }

    var category: Driver<String> {
        categoryRelay.asDriver(onErrorDriveWith: .empty())
    }

    var segmentIndex: Driver<Int> {
        segmentIndexRelay.asDriver(onErrorDriveWith: .empty())
    }

    var balance: Driver<String> {
        balanceRelay.asDriver(onErrorDriveWith: .empty())
    }

    var memo: Driver<String> {
        memoRelay.asDriver(onErrorDriveWith: .empty())
    }

    var incomeCategory: Driver<[CategoryData]> {
        incomeCategoryRelay.asDriver(onErrorDriveWith: .empty())
    }

    var expenseCategory: Driver<[CategoryData]> {
        expenseCategoryRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapSaveButton(data: KakeiboData) {
        guard let userInfo = userInfo else {
            let alertTitle = "アカウントが見つかりません。"
            let message = "データの保存はログイン状態で行う必要があります。 \n アカウント画面からログインしてください。"
            eventRelay.accept(.presetDismissAlert(alertTitle, message))
            return
        }
        switch mode {
        case .add:
            kakeiboModel.addData(userId: userInfo.id, data: data)
        case .edit(let beforeData):
            guard let firstIndex = kakeiboDataArray.firstIndex(where: { $0 == beforeData }) else { return }
            kakeiboModel.updateData(userId: userInfo.id, index: firstIndex, data: data)
        }
        eventRelay.accept(.dismiss)
    }

    func didTapCancelButton() {
        eventRelay.accept(.dismiss)
    }

    func addDate(date: Date) {
        dateRelay.accept(DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日"))
        categoryRelay.accept(expenseCategoryRelay.value.first?.name ?? "")
    }

    func editData(data: KakeiboData) {
        dateRelay.accept(DateUtility.stringFromDate(date: data.date, format: "yyyy年MM月dd日"))
        switch data.categoryId {
        case .income(let id): // swiftlint:disable:this identifier_name
            var categoryData: CategoryData?
            let incomeCategoryArray = incomeCategoryRelay.value
            incomeCategoryArray.forEach { if $0.id == id { categoryData = $0 } }
            if let categoryData = categoryData {
                categoryRelay.accept(categoryData.name)
            } else {
                categoryRelay.accept("") // idが一致しないエラー
            }
        case .expense(let id): // swiftlint:disable:this identifier_name
            var categoryData: CategoryData?
            let expenseCategoryArray = expenseCategoryRelay.value
            expenseCategoryArray.forEach { if $0.id == id { categoryData = $0 } }
            if let categoryData = categoryData {
                categoryRelay.accept(categoryData.name)
            } else {
                categoryRelay.accept("") // idが一致しないエラー
            }
        }
        switch data.balance {
        case .income(let income):
            segmentIndexRelay.accept(1)
            balanceRelay.accept(String(income))
        case .expense(let expense):
            segmentIndexRelay.accept(0)
            balanceRelay.accept(String(expense))
        }
        memoRelay.accept(data.memo)
    }

    func didTapNextDayButton() {
        let date = DateUtility.dateFromString(stringDate: dateRelay.value, format: "yyyy年MM月dd日")
        let carendar = Calendar(identifier: .gregorian)
        guard let nextDay = carendar.date(
            byAdding: .day, value: 1, to: date
        ) else { return }
        dateRelay.accept(DateUtility.stringFromDate(date: nextDay, format: "yyyy年MM月dd日"))
    }

    func didTapLastDayButton() {
        let date = DateUtility.dateFromString(stringDate: dateRelay.value, format: "yyyy年MM月dd日")
        let carendar = Calendar(identifier: .gregorian)
        guard let lastDay = carendar.date(
            byAdding: .day, value: -1, to: date
        ) else { return }
        dateRelay.accept(DateUtility.stringFromDate(date: lastDay, format: "yyyy年MM月dd日"))
    }
}

// MARK: - InputViewModelType
extension InputViewModel: InputViewModelType {
    var inputs: InputViewModelInput {
        return self
    }

    var outputs: InputViewModelOutput {
        return self
    }
}
