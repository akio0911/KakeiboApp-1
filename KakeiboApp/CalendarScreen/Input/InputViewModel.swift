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
    func didTapSaveButton(balanceText: String, memo: String)
    func didTapCancelButton()
    func didTapNextDayButton()
    func didTapLastDayButton()
    func didChangeDatePicker(date: Date)
    func didChangeSegmentControl(index: Int)
    func didSelectCategory(name: String?)
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
    var date: Driver<String> { get }
    var category: Driver<String?> { get }
    var segmentIndex: Driver<Int> { get }
    var balance: Driver<String> { get }
    var memo: Driver<String> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
    var incomeCategoryDataArray: [CategoryData] { get }
    var expenseCategoryDataArray: [CategoryData] { get }
}

protocol InputViewModelType {
    var inputs: InputViewModelInput { get }
    var outputs: InputViewModelOutput { get }
}

final class InputViewModel: InputViewModelInput, InputViewModelOutput {
    enum Event {
        case dismiss
        case showDismissAlert(String, String)
        case showErrorAlert
        case showAlert(String, String)
    }

    enum Mode {
        case add(Date)
        case edit(KakeiboData, CategoryData)
    }

    private let mode: Mode
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let eventRelay = PublishRelay<Event>()
    private let dateRelay = BehaviorRelay<String>(value: "")
    private let categoryRelay = BehaviorRelay<String?>(
        value: R.string.localizable.consumptionExpenses()
    )
    private let segmentIndexRelay = BehaviorRelay<Int>(value: 0)
    private let balanceRelay = BehaviorRelay<String>(value: "")
    private let memoRelay = BehaviorRelay<String>(value: "")
    private let isAnimatedIndicatorRelay = PublishRelay<Bool>()

    private(set) var incomeCategoryDataArray: [CategoryData]
    private(set) var expenseCategoryDataArray: [CategoryData]

    init(kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         mode: Mode,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        self.mode = mode
        self.authType = authType
        incomeCategoryDataArray = categoryModel.incomeCategoryDataArray
        expenseCategoryDataArray = categoryModel.expenseCategoryDataArray
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    var date: Driver<String> {
        dateRelay.asDriver()
    }

    var category: Driver<String?> {
        categoryRelay.asDriver()
    }

    var segmentIndex: Driver<Int> {
        segmentIndexRelay.asDriver()
    }

    var balance: Driver<String> {
        balanceRelay.asDriver()
    }

    var memo: Driver<String> {
        memoRelay.asDriver()
    }

    var isAnimatedIndicator: Driver<Bool> {
        isAnimatedIndicatorRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewDidLoad() {
        switch mode {
        case .add(let date):
            setupAddMode(date: date)
        case .edit(let kakeiboData, let categoryData):
            setupEditMode(kakeiboData: kakeiboData, categoryData: categoryData)
        }
    }

    func didTapSaveButton(balanceText: String, memo: String) {
        guard let userInfo = authType.userInfo else {
            let alertTitle = R.string.localizable.userNotFoundErrorTitle()
            let message = R.string.localizable.dataSaveErrorOnNonLogin()
            eventRelay.accept(.showDismissAlert(alertTitle, message))
            return
        }

        let date = DateUtility.dateFromString(stringDate: dateRelay.value, format: "yyyy年MM月dd日")
        let categoryId: CategoryId
        let balance: Balance
        switch segmentIndexRelay.value {
        case 0:
            // 支出
            guard let categoryDataId = expenseCategoryDataArray.first(where: { $0.name == categoryRelay.value })?.id,
                  let balanceInt = Int(balanceText) else {
                eventRelay.accept(.showAlert(
                        R.string.localizable.categoryOrBalanceValidationErrorTitle(),
                        R.string.localizable.categoryOrBalanceValidationErrorMessage()
                ))
                return
            }
            categoryId = CategoryId.expense(categoryDataId)
            balance = Balance.expense(balanceInt)
        case 1:
            // 収入
            guard let categoryDataId = incomeCategoryDataArray.first(where: { $0.name == categoryRelay.value })?.id,
                  let balanceInt = Int(balanceText) else {
                eventRelay.accept(.showAlert(
                        R.string.localizable.categoryOrBalanceValidationErrorTitle(),
                        R.string.localizable.categoryOrBalanceValidationErrorMessage()
                ))
                return
            }
            categoryId = CategoryId.income(categoryDataId)
            balance = Balance.income(balanceInt)
        default:
            fatalError("想定していないIndex")
        }

        switch mode {
        case .add:
            let data = KakeiboData(date: date, categoryId: categoryId, balance: balance, memo: memo)
            isAnimatedIndicatorRelay.accept(true)
            kakeiboModel.setData(userId: userInfo.id, data: data) { [weak self] error in
                self?.isAnimatedIndicatorRelay.accept(false)
                if error != nil {
                    self?.eventRelay.accept(.showErrorAlert)
                    return
                }
            }
        case .edit(var beforeData, _):
            beforeData.date = date
            beforeData.categoryId = categoryId
            beforeData.balance = balance
            beforeData.memo = memoRelay.value
            isAnimatedIndicatorRelay.accept(true)
            kakeiboModel.setData(userId: userInfo.id, data: beforeData) { [weak self] error in
                self?.isAnimatedIndicatorRelay.accept(false)
                if error != nil {
                    self?.eventRelay.accept(.showErrorAlert)
                    return
                }
            }
        }
        eventRelay.accept(.dismiss)
    }

    func didTapCancelButton() {
        eventRelay.accept(.dismiss)
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

    func didChangeDatePicker(date: Date) {
        dateRelay.accept(DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日"))
    }

    func didChangeSegmentControl(index: Int) {
        segmentIndexRelay.accept(index)
        switch index {
        case 0:
            // 支出
            categoryRelay.accept(expenseCategoryDataArray.first?.name ?? "")
        case 1:
            // 収入
            categoryRelay.accept(incomeCategoryDataArray.first?.name ?? "")
        default:
            break
        }
    }

    func didSelectCategory(name: String?) {
        categoryRelay.accept(name)
    }

    // MARK: - misc
    private func setupAddMode(date: Date) {
        dateRelay.accept(DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日"))
    }

    private func setupEditMode(kakeiboData: KakeiboData, categoryData: CategoryData) {
        dateRelay.accept(DateUtility.stringFromDate(date: kakeiboData.date, format: "yyyy年MM月dd日"))
        categoryRelay.accept(categoryData.name)
        segmentIndexRelay.accept(kakeiboData.categoryId.rawValue)
        balanceRelay.accept(String(kakeiboData.balance.fetchValue))
        memoRelay.accept(kakeiboData.memo)
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
