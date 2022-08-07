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
    func onViewWillApper()
    func didTapInputButton(date: Date?)
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(kakeiboData: KakeiboData, categoryData: CategoryData)
    func didDeleateCell(kakeiboData: KakeiboData)
}

protocol CalendarViewModelOutput {
    var collectionViewItemsObservable: Observable<[Date]> { get }
    var navigationTitle: Driver<String> { get }
    var incomeText: Driver<String> { get }
    var expenseText: Driver<String> { get }
    var balanceTxet: Driver<String> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
    var event: Driver<CalendarViewModel.Event> { get }
    func loadCalendarItems(date: Date) -> [CalendarItem]
    func loadCalendarItem(date: Date) -> CalendarItem
}

protocol CalendarViewModelType {
    var inputs: CalendarViewModelInput { get }
    var outputs: CalendarViewModelOutput { get }
}

final class CalendarViewModel: CalendarViewModelInput, CalendarViewModelOutput {
    enum Event {
        case selectedAdd(Date)
        case selectedEdit(KakeiboData, CategoryData)
        case showErrorAlert(Error)
        case reloadData
    }

    private let kakeiboModel: KakeiboModelProtocol
    private let calendarDate: CalendarDateProtocol
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let collectionViewItemsRelay = BehaviorRelay<[Date]>(value: [])
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
                self?.acceptCollectionViewItems()
                self?.acceptTotalText()
            }
            .disposed(by: disposeBag)
    }
    private func acceptCollectionViewItems() {
        collectionViewItemsRelay.accept((-120...120).map { month in
            guard let date = Calendar(identifier: .gregorian)
                .date(byAdding: .month, value: month, to: displayDate) else {
                return Date()
            }
            return date
        })
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

    var collectionViewItemsObservable: Observable<[Date]> {
        collectionViewItemsRelay.asObservable()
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

    func loadCalendarItems(date: Date) -> [CalendarItem] {
        guard let year = Int(DateUtility.stringFromDate(date: date, format: "yyyy")),
              let month = Int(DateUtility.stringFromDate(date: date, format: "MM")) else {
            return []
        }
        var calendarItems: [CalendarItem] = []
        let calendarDateArray = calendarDate.loadCalendarDate(year: year, month: month, isContainOtherMonth: true)
        calendarDateArray.forEach { calendarDate in
            let kakeiboDataArray = kakeiboModel.loadDayData(date: calendarDate)
            let totalBalance = kakeiboDataArray.reduce(0) { $0 + $1.balance.fetchValueSigned }
            let isCalendarMonth = Calendar(identifier: .gregorian)
                .isDate(calendarDate, equalTo: date, toGranularity: .month)
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
            calendarItems.append(
                CalendarItem(
                    date: calendarDate,
                    totalBalance: totalBalance,
                    isCalendarMonth: isCalendarMonth,
                    dataArray: dataArray
                )
            )
        }
        return calendarItems
    }

    func loadCalendarItem(date: Date) -> CalendarItem {
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
        return CalendarItem(
            date: date,
            totalBalance: totalBalance,
            isCalendarMonth: isCalendarMonth,
            dataArray: dataArray
        )
    }

    func onViewDidLoad() {
        navigationTitleRelay.accept(DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))
    }

    func onViewWillApper() {
        acceptTotalText()
        eventRelay.accept(.reloadData)
    }

    func didTapInputButton(date: Date?) {
        if let date = date {
            eventRelay.accept(.selectedAdd(date))
        } else {
            eventRelay.accept(.selectedAdd(Date()))
        }
    }

    func didActionNextMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: displayDate) {
            self.displayDate = displayDate
            acceptTotalText()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didActionLastMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: -1, to: displayDate) {
            self.displayDate = displayDate
            acceptTotalText()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didSelectRowAt(kakeiboData: KakeiboData, categoryData: CategoryData) {
        eventRelay.accept(.selectedEdit(kakeiboData, categoryData))
    }

    func didDeleateCell(kakeiboData: KakeiboData) {
        guard let userInfo = authType.userInfo else { return }
        isAnimatedIndicatorRelay.accept(true)
        kakeiboModel.deleateData(userId: userInfo.id, data: kakeiboData) { [weak self] error in
            self?.isAnimatedIndicatorRelay.accept(false)
            if let error = error {
                self?.eventRelay.accept(.showErrorAlert(error))
            } else {
                self?.acceptTotalText()
                self?.eventRelay.accept(.reloadData)
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
