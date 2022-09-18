//
//  InputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import RxSwift
import RxCocoa

protocol InputViewModelInput {
    func setMode(mode: InputViewModel.Mode)
    func didTapSaveButton(dateText: String, segmentIndex: Int, balanceText: String, categoryData: CategoryData, memo: String)
    func didTapDeleteButton()
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
    var date: Driver<String> { get }
    var category: Driver<([[CategoryData]], selectedIndexPath: IndexPath)> { get }
    var segmentIndex: Driver<Int> { get }
    var balance: Driver<String> { get }
    var memo: Driver<String> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
    var isHiddenDeleteButton: Driver<Bool> { get }
}

protocol InputViewModelType {
    var inputs: InputViewModelInput { get }
    var outputs: InputViewModelOutput { get }
}

final class InputViewModel: InputViewModelInput, InputViewModelOutput {
    enum Event {
        case showPopViewAlert(String, String?)
        case showErrorAlert
        case showAlert(String, String?)
    }

    enum Mode {
        case add(Date)
        case edit(KakeiboData, CategoryData)
    }

    private var mode: Mode = .add(Date()) {
        didSet {
            switch mode {
            case .add(let date):
                setupAddMode(date: date)
            case .edit(let kakeiboData, let categoryData):
                setupEditMode(kakeiboData: kakeiboData, categoryData: categoryData)
            }
        }
    }
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let eventRelay = PublishRelay<Event>()
    private let dateRelay = PublishRelay<String>()
    private let categoryRelay = PublishRelay<([[CategoryData]], selectedIndexPath: IndexPath)>()
    private let segmentIndexRelay = PublishRelay<Int>()
    private let balanceRelay = BehaviorRelay<String>(value: "")
    private let memoRelay = BehaviorRelay<String>(value: "")
    private let isAnimatedIndicatorRelay = PublishRelay<Bool>()
    private let isHiddenDeleteButtonRelay = PublishRelay<Bool>()

    private var balanceCategoryDataArray: [[CategoryData]] {
        return [
            categoryModel.expenseCategoryDataArray,
            categoryModel.incomeCategoryDataArray
        ]
    }

    init(kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        self.authType = authType
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    var date: Driver<String> {
        dateRelay.asDriver(onErrorDriveWith: .empty())
    }

    var category: Driver<([[CategoryData]], selectedIndexPath: IndexPath)> {
        categoryRelay.asDriver(onErrorDriveWith: .empty())
    }

    var segmentIndex: Driver<Int> {
        segmentIndexRelay.asDriver(onErrorDriveWith: .empty())
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

    var isHiddenDeleteButton: Driver<Bool> {
        isHiddenDeleteButtonRelay.asDriver(onErrorDriveWith: .empty())
    }

    func setMode(mode: Mode) {
        self.mode = mode
    }

    func didTapSaveButton(dateText: String, segmentIndex: Int, balanceText: String, categoryData: CategoryData, memo: String) {
        guard let userInfo = authType.userInfo else {
            let alertTitle = R.string.localizable.userNotFoundErrorTitle()
            let message = R.string.localizable.dataSaveErrorOnNonLogin()
            eventRelay.accept(.showPopViewAlert(alertTitle, message))
            return
        }

        let date = DateUtility.dateFromString(stringDate: dateText, format: "yyyy年MM月dd日")
        let categoryId: CategoryId
        let balance: Balance
        switch segmentIndex {
        case 0:
            // 支出
            guard let balanceInt = Int(balanceText.filter { Int(String($0)) != nil }) else {
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
            guard let balanceInt = Int(balanceText.filter { Int(String($0)) != nil }) else {
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
                } else {
                    self?.eventRelay.accept(.showPopViewAlert(R.string.localizable.saveComplete(), nil))
                    self?.mode = .add(date)
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
                } else {
                    self?.eventRelay.accept(.showPopViewAlert(R.string.localizable.saveComplete(), nil))
                    self?.mode = .add(Date())
                }
            }
        }
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
                    self?.eventRelay.accept(.showPopViewAlert(R.string.localizable.deletedTitle(), nil))
                    self?.mode = .add(Date())
                }
            }
        }
    }

    // MARK: - misc
    private func setupAddMode(date: Date) {
        dateRelay.accept(DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日"))
        categoryRelay.accept(
            (balanceCategoryDataArray, selectedIndexPath: [0, 0])
        )
        segmentIndexRelay.accept(0)
        balanceRelay.accept("0")
        memoRelay.accept("")
        isHiddenDeleteButtonRelay.accept(true)
        segmentIndexRelay.accept(0)
    }

    private func setupEditMode(kakeiboData: KakeiboData, categoryData: CategoryData) {
        dateRelay.accept(DateUtility.stringFromDate(date: kakeiboData.date, format: "yyyy年MM月dd日"))
        switch kakeiboData.categoryId {
        case .expense:
            categoryRelay.accept(
                (balanceCategoryDataArray, selectedIndexPath: [0, categoryData.displayOrder])
            )
            segmentIndexRelay.accept(0)
        case .income:
            categoryRelay.accept(
                (balanceCategoryDataArray, selectedIndexPath: [1, categoryData.displayOrder])
            )
            segmentIndexRelay.accept(1)
        }
        segmentIndexRelay.accept(kakeiboData.categoryId.rawValue)
        balanceRelay.accept(NumberFormatterUtility.changeToDecimal(from: kakeiboData.balance.fetchValue) ?? "0")
        memoRelay.accept(kakeiboData.memo)
        isHiddenDeleteButtonRelay.accept(false)
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
