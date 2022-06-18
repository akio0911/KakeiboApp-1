//
//  InputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import RxSwift
import RxCocoa

protocol InputViewModelInput {
    func onViewDidLoad()
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

    // TODO: ViewControllerからの呼び出し部を実装
    func onViewDidLoad() {
        incomeCategoryRelay.accept(categoryModel.incomeCategoryDataArray)
        expenseCategoryRelay.accept(categoryModel.expenseCategoryDataArray)
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
            // TODO: インジケータ表示
            kakeiboModel.setData(userId: userInfo.id, data: data) { [weak self] error in
                if let error = error {
                    // TODO: エラー処理の追加とインジケータ非表示
                    return
                }
            }
        case .edit(var beforeData):
            beforeData.date = data.date
            beforeData.categoryId = data.categoryId
            beforeData.balance = data.balance
            beforeData.memo = data.memo
            // TODO: インジケータ表示
            kakeiboModel.setData(userId: userInfo.id, data: beforeData) { [weak self] error in
                if let error = error {
                    // TODO: エラー処理の追加とインジケータ非表示
                    return
                }
            }
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
