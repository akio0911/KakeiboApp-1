//
//  CalendarViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxCocoa
import Foundation

protocol CalendarViewModelInput {
    func onViewDidLoad()
    func didTapInputBarButton(didHighlightItem indexPath: IndexPath)
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(indexPath: IndexPath)
    func didDeleateCell(indexPath: IndexPath)
}

protocol CalendarViewModelOutput {
    var collectionViewItemObservable: Observable<[CalendarItem]> { get }
    var tableViewItemObservable: Observable<[CalendarItem]> { get }
    var navigationTitle: Driver<String> { get }
    var incomeText: Driver<String> { get }
    var expenseText: Driver<String> { get }
    var balanceTxet: Driver<String> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
    var event: Driver<CalendarViewModel.Event> { get }
}

protocol CalendarViewModelType {
    var inputs: CalendarViewModelInput { get }
    var outputs: CalendarViewModelOutput { get }
}

final class CalendarViewModel: CalendarViewModelInput, CalendarViewModelOutput {
    enum Event {
        case presentAdd(Date)
        case presentEdit(KakeiboData)
        case showErrorAlert(Error) // TODO: viewControllerに処理部を追加
    }

    private let kakeiboModel: KakeiboModelProtocol
    private let calendarDate: CalendarDateProtocol
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let collectionViewItemRelay = BehaviorRelay<[CalendarItem]>(value: [])
    private let tableViewItemRelay = BehaviorRelay<[CalendarItem]>(value: [])
    private let incomeTextRelay = PublishRelay<String>()
    private let expenseTextRelay = PublishRelay<String>()
    private let balanceTextRelay = PublishRelay<String>()
    private let isAnimatedIndicatorRelay = PublishRelay<Bool>()
    private let navigationTitleRelay = PublishRelay<String>()
    private let eventRelay = PublishRelay<Event>()
    private var displayDate = Date()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.calendarDate = calendarDate
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        self.authType = authType
        setupBinding()
    }

    private func setupBinding() {
        EventBus.setupData.asObservable()
            .subscribe { [weak self] _ in
                self?.acceptCollectionViewItem()
                self?.acceptTableViewItem()
                self?.acceptTotalText()
            }
            .disposed(by: disposeBag)
    }

    private func acceptCollectionViewItem() {
        guard let year = Int(DateUtility.stringFromDate(date: displayDate, format: "yyyy")),
              let month = Int(DateUtility.stringFromDate(date: displayDate, format: "MM")) else {
            return
        }

        var collectionViewItem: [CalendarItem] = []
        let calendarDateArray = calendarDate.loadCalendarDate(year: year, month: month, isContainOtherMonth: true)
        calendarDateArray.forEach { date in
            let kakeiboDataArray = kakeiboModel.loadDayData(date: date)
            let totalBalance = kakeiboDataArray.reduce(0) { $0 + $1.balance.fetchValueSigned }
            let isCalendarMonth = Calendar(identifier: .gregorian)
                .isDate(date, equalTo: displayDate, toGranularity: .month)
            let dataArray = kakeiboDataArray.map { kakeiboData -> (CategoryData, KakeiboData) in
                switch kakeiboData.categoryId {
                case .income(let categoryId):
                    let categoryData = categoryModel.incomeCategoryDataArray.first { $0.id == categoryId } ??
                    CategoryData(id: categoryId, displayOrder: 999, name: "", color: .red)
                    return (categoryData, kakeiboData)
                case .expense(let categoryId):
                    let categoryData = categoryModel.expenseCategoryDataArray.first { $0.id == categoryId } ??
                    CategoryData(id: categoryId, displayOrder: 999, name: "", color: .red)
                    return (categoryData, kakeiboData)
                }
            }
            collectionViewItem.append(
                CalendarItem(
                    date: date, totalBalance: totalBalance, isCalendarMonth: isCalendarMonth, dataArray: dataArray
                )
            )
        }
        collectionViewItemRelay.accept(collectionViewItem)
    }

    private func acceptTableViewItem() {
        guard let year = Int(DateUtility.stringFromDate(date: displayDate, format: "yyyy")),
              let month = Int(DateUtility.stringFromDate(date: displayDate, format: "MM")) else {
            return
        }

        var tableViewItem: [CalendarItem] = []
        let calendarDateArray = calendarDate.loadCalendarDate(year: year, month: month, isContainOtherMonth: false)
        calendarDateArray.forEach { date in
            let kakeiboDataArray = kakeiboModel.loadDayData(date: date)
            guard !kakeiboDataArray.isEmpty else { return }
            let totalBalance = kakeiboDataArray.reduce(0) { $0 + $1.balance.fetchValueSigned }
            let isCalendarMonth = Calendar(identifier: .gregorian)
                .isDate(date, equalTo: displayDate, toGranularity: .month)
            let dataArray = kakeiboDataArray.map { kakeiboData -> (CategoryData, KakeiboData) in
                switch kakeiboData.categoryId {
                case .income(let categoryId):
                    let categoryData = categoryModel.incomeCategoryDataArray.first { $0.id == categoryId } ??
                    CategoryData(id: categoryId, displayOrder: 999, name: "", color: .red)
                    return (categoryData, kakeiboData)
                case .expense(let categoryId):
                    let categoryData = categoryModel.expenseCategoryDataArray.first { $0.id == categoryId } ??
                    CategoryData(id: categoryId, displayOrder: 999, name: "", color: .red)
                    return (categoryData, kakeiboData)
                }
            }
            tableViewItem.append(
                CalendarItem(
                    date: date, totalBalance: totalBalance, isCalendarMonth: isCalendarMonth, dataArray: dataArray
                )
            )
        }
        tableViewItemRelay.accept(tableViewItem)
    }

    private func acceptTotalText() {
        var totalIncome = 0
        var totalExpense = 0
        var totalBalance = 0

        let kakeiboDataArray = kakeiboModel.loadMonthData(date: displayDate)
        kakeiboDataArray.forEach {
            switch $0.balance {
            case .income(let income):
                totalIncome += income
            case .expense(let expense):
                totalExpense += expense
            }
        }
        totalBalance = totalIncome - totalExpense

        let totalIncomeText = NumberFormatterUtility.changeToCurrencyNotation(from: totalIncome) ?? "0円"
        let totalExpenseText = NumberFormatterUtility.changeToCurrencyNotation(from: totalExpense) ?? "0円"
        let totalBalanceText = NumberFormatterUtility.changeToCurrencyNotation(from: totalBalance) ?? "0円"
        incomeTextRelay.accept(totalIncomeText)
        expenseTextRelay.accept(totalExpenseText)
        balanceTextRelay.accept(totalBalanceText)
    }

    var collectionViewItemObservable: Observable<[CalendarItem]> {
        collectionViewItemRelay.asObservable()
    }

    var tableViewItemObservable: Observable<[CalendarItem]> {
        tableViewItemRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var incomeText: Driver<String> {
        incomeTextRelay.asDriver(onErrorDriveWith: .empty())
    }

    var expenseText: Driver<String> {
        expenseTextRelay.asDriver(onErrorDriveWith: .empty())
    }

    var balanceTxet: Driver<String> {
        balanceTextRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isAnimatedIndicator: Driver<Bool> {
        isAnimatedIndicatorRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewDidLoad() {
        acceptCollectionViewItem()
        acceptTableViewItem()
        acceptTotalText()
        navigationTitleRelay.accept(DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))
    }

    func didTapInputBarButton(didHighlightItem indexPath: IndexPath) {
        if indexPath.isEmpty {
            eventRelay.accept(.presentAdd(Date()))
        } else {
            let calendarItemArray = collectionViewItemRelay.value
            let date = calendarItemArray[indexPath.row].date
            eventRelay.accept(.presentAdd(date))
        }
    }

    func didActionNextMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: displayDate) {
            self.displayDate = displayDate
            acceptCollectionViewItem()
            acceptTableViewItem()
            acceptTotalText()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didActionLastMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: -1, to: displayDate) {
            self.displayDate = displayDate
            acceptCollectionViewItem()
            acceptTableViewItem()
            acceptTotalText()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didSelectRowAt(indexPath: IndexPath) {
        let kakeiboData = tableViewItemRelay.value[indexPath.section].dataArray[indexPath.row].1
        eventRelay.accept(.presentEdit(kakeiboData))
    }

    func didDeleateCell(indexPath: IndexPath) {
        guard let userInfo = authType.userInfo else { return }
        let kakeiboData = tableViewItemRelay.value[indexPath.section].dataArray[indexPath.row].1
        isAnimatedIndicatorRelay.accept(true)
        kakeiboModel.deleateData(userId: userInfo.id, data: kakeiboData) { [weak self] error in
            self?.isAnimatedIndicatorRelay.accept(false)
            if let error = error {
                self?.eventRelay.accept(.showErrorAlert(error))
            }
        }
    }
}

// MARK: - CalendarViewModelType
extension CalendarViewModel: CalendarViewModelType {
    var inputs: CalendarViewModelInput {
        return self
    }

    var outputs: CalendarViewModelOutput {
        return self
    }
}
