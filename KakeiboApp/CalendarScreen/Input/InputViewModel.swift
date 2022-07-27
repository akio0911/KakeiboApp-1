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
    func didTapSaveButton(dateText: String, balanceText: String, categoryData: CategoryData, memo: String)
    func didTapDeleteButton()
    func didChangeSegmentControl(index: Int)
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
    var date: Driver<String> { get }
    var category: Driver<([CategoryData], selectedIndex: Int)> { get }
    var segmentIndex: Driver<Int> { get }
    var balance: Driver<String> { get }
    var memo: Driver<String> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
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
        case showAlert(String, String?)
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
    private let dateRelay = PublishRelay<String>()
    private let categoryRelay = PublishRelay<([CategoryData], selectedIndex: Int)>()
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
        dateRelay.asDriver(onErrorDriveWith: .empty())
    }

    var category: Driver<([CategoryData], selectedIndex: Int)> {
        categoryRelay.asDriver(onErrorDriveWith: .empty())
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

    func didTapSaveButton(dateText: String, balanceText: String, categoryData: CategoryData, memo: String) {
        guard let userInfo = authType.userInfo else {
            let alertTitle = R.string.localizable.userNotFoundErrorTitle()
            let message = R.string.localizable.dataSaveErrorOnNonLogin()
            eventRelay.accept(.showDismissAlert(alertTitle, message))
            return
        }

        let date = DateUtility.dateFromString(stringDate: dateText, format: "yyyy年MM月dd日")
        let categoryId: CategoryId
        let balance: Balance
        switch segmentIndexRelay.value {
        case 0:
            // 支出
            guard let balanceInt = Int(balanceText) else {
                eventRelay.accept(.showAlert(
                        R.string.localizable.categoryOrBalanceValidationErrorTitle(),
                        R.string.localizable.categoryOrBalanceValidationErrorMessage()
                ))
                return
            }
            categoryId = CategoryId.expense(categoryData.id)
            balance = Balance.expense(balanceInt)
        case 1:
            // 収入
            guard let balanceInt = Int(balanceText) else {
                eventRelay.accept(.showAlert(
                        R.string.localizable.categoryOrBalanceValidationErrorTitle(),
                        R.string.localizable.categoryOrBalanceValidationErrorMessage()
                ))
                return
            }
            categoryId = CategoryId.income(categoryData.id)
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

    func didTapDeleteButton() {
        guard let userInfo = authType.userInfo else { return }
        switch mode {
        case .add:
            break
        case .edit(let kakeiboData, _):
            isAnimatedIndicatorRelay.accept(true)
            kakeiboModel.deleateData(userId: userInfo.id, data: kakeiboData) { [weak self] error in
                self?.isAnimatedIndicatorRelay.accept(false)
                if error != nil {
                    self?.eventRelay.accept(.showErrorAlert)
                } else {
                    self?.eventRelay.accept(.showAlert(R.string.localizable.deletedTitle(), nil))
                }
            }
        }
    }

    func didChangeSegmentControl(index: Int) {
        segmentIndexRelay.accept(index)
        switch index {
        case 0:
            // 支出
            categoryRelay.accept((categoryModel.expenseCategoryDataArray, selectedIndex: 0))
        case 1:
            // 収入
            categoryRelay.accept((categoryModel.incomeCategoryDataArray, selectedIndex: 0))
        default:
            break
        }
    }

    // MARK: - misc
    private func setupAddMode(date: Date) {
        dateRelay.accept(DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日"))
        categoryRelay.accept((categoryModel.expenseCategoryDataArray, selectedIndex: 0))
    }

    private func setupEditMode(kakeiboData: KakeiboData, categoryData: CategoryData) {
        dateRelay.accept(DateUtility.stringFromDate(date: kakeiboData.date, format: "yyyy年MM月dd日"))
        switch kakeiboData.categoryId {
        case .expense:
            categoryRelay.accept((categoryModel.expenseCategoryDataArray, selectedIndex: categoryData.displayOrder))
        case .income:
            categoryRelay.accept((categoryModel.incomeCategoryDataArray, selectedIndex: categoryData.displayOrder))
        }
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
