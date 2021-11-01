//
//  CalendarViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxCocoa

protocol CalendarViewModelInput {
    func didTapInputBarButton(didHighlightItem indexPath: IndexPath)
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(index: IndexPath)
    func didDeleateCell(index: IndexPath)
}

protocol CalendarViewModelOutput {
    var dayItemDataObservable: Observable<[DayItemData]> { get }
    var cellDateDataObservable: Observable<[[CellDateKakeiboData]]> { get }
    var headerDateDataObservable: Observable<[HeaderDateKakeiboData]> { get }
    var navigationTitle: Driver<String> { get }
    var incomeText: Driver<String> { get }
    var expenseText: Driver<String> { get }
    var balanceTxet: Driver<String> { get }
    //    var isAnimatedIndicator: Driver<Bool> { get }
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
    }

    private let model: KakeiboModelProtocol
    private let calendarDate: CalendarDateProtocol
    private let categoryModel: CategoryModelProtocol
    private let disposeBag = DisposeBag()
    private let dayItemDataRelay = BehaviorRelay<[DayItemData]>(value: [])
    private let cellDateDataRelay = BehaviorRelay<[[CellDateKakeiboData]]>(value: [])
    private let headerDateDataRelay = BehaviorRelay<[HeaderDateKakeiboData]>(value: [])
    private let incomeTextRelay = BehaviorRelay<String>(value: "")
    private let expenseTextRelay = BehaviorRelay<String>(value: "")
    private let balanceTextRelay = BehaviorRelay<String>(value: "")
    //    private let isAnimatedIndicatorRelay = BehaviorRelay<Bool>(value: true)
    private let eventRelay = PublishRelay<Event>()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         model: KakeiboModelProtocol = ModelLocator.shared.model,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel) {
        self.calendarDate = calendarDate
        self.model = model
        self.categoryModel = categoryModel
        setupBinding()
    }

    private var calendarDateArray: [Date] = []
    private var monthDateArray: [Date] = []
    private var kakeiboDataArray: [KakeiboData] = []
    private var incomeCategoryArray: [CategoryData] = []
    private var expenseCategoryArray: [CategoryData] = []

    private func setupBinding() {

        calendarDate.calendarDate
            .subscribe(onNext: { calendarDateArray in
                self.calendarDateArray = calendarDateArray
            })
            .disposed(by: disposeBag)

        calendarDate.monthDate
            .subscribe(onNext: { monthDateArray in
                self.monthDateArray = monthDateArray
                self.acceptDayItemData()
                self.acceptCellDateData()
                self.acceptHeaderDateDataArray()
                self.acceptTotalText()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { kakeiboDataArray in
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptDayItemData()
                self.acceptCellDateData()
                self.acceptHeaderDateDataArray()
                self.acceptTotalText()
            })
            .disposed(by: disposeBag)

        categoryModel.incomeCategoryData
            .subscribe(onNext: { incomeCategoryArray in
                self.incomeCategoryArray = incomeCategoryArray
                self.acceptCellDateData()
            })
            .disposed(by: disposeBag)

        categoryModel.expenseCategoryData
            .subscribe(onNext: { expenseCategoryArray in
                self.expenseCategoryArray = expenseCategoryArray
                self.acceptCellDateData()
            })
            .disposed(by: disposeBag)
    }

    private func acceptDayItemData() {
        guard !monthDateArray.isEmpty else { return }
        let firstDay = monthDateArray[0] // 月の初日

        var dayItemDataArray: [DayItemData] = []

        calendarDateArray.forEach {
            let date = $0
            let dateDataArray = kakeiboDataArray.filter { $0.date == date }
            let totalBalance = dateDataArray.reduce(0) { $0 + $1.balance.fetchValueSigned }
            let isCalendarMonth =
            Calendar(identifier: .gregorian).isDate(date, equalTo: firstDay, toGranularity: .year)
            && Calendar(identifier: .gregorian).isDate(date, equalTo: firstDay, toGranularity: .month)
            dayItemDataArray.append(
                DayItemData(date: date, totalBalance: totalBalance, isCalendarMonth: isCalendarMonth)
            )
        }
        dayItemDataRelay.accept(dayItemDataArray)
    }

    private func acceptCellDateData() {
        var cellDateDataArray: [[CellDateKakeiboData]] = []
        monthDateArray.forEach {
            var cellDateData: [CellDateKakeiboData] = []
            let date = $0
            let dateDataArray = kakeiboDataArray.filter { $0.date == date }
            dateDataArray.forEach {
                // categoryIdからCategoryDataに変換
                var categoryData: CategoryData
                switch $0.categoryId {
                case .income(let id):
                    categoryData = incomeCategoryArray.first { $0.id == id } ??
                    CategoryData(id: "", displayOrder: 999, name: "", color: .red)
                case .expense(let id):
                    categoryData = expenseCategoryArray.first { $0.id == id } ??
                    CategoryData(id: "", displayOrder: 999, name: "", color: .red)
                }

                cellDateData.append(
                    CellDateKakeiboData(categoryData: categoryData, balance: $0.balance, memo: $0.memo)
                )
            }
            if !cellDateData.isEmpty {
                cellDateDataArray.append(cellDateData)
            }
        }
        cellDateDataRelay.accept(cellDateDataArray)
    }

    private func acceptHeaderDateDataArray() {
        var headerDateDataArray: [HeaderDateKakeiboData] = []
        monthDateArray.forEach {
            let date = $0
            var totalBalance = 0
            let dateDataArray = kakeiboDataArray.filter { $0.date == date }
            if !dateDataArray.isEmpty {
                totalBalance = dateDataArray.reduce(0) { $0 + $1.balance.fetchValueSigned }
                headerDateDataArray.append(HeaderDateKakeiboData(date: date, totalBalance: totalBalance))
            }
        }
        headerDateDataRelay.accept(headerDateDataArray)
    }

    private func acceptTotalText() {
        guard !monthDateArray.isEmpty else { return }
        let firstDay = monthDateArray[0] // 月の初日

        var totalIncome = 0
        var totalExpense = 0
        var totalBalance = 0

        let monthKakeiboData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian).isDate($0.date, equalTo: firstDay, toGranularity: .year)
            && Calendar(identifier: .gregorian).isDate($0.date, equalTo: firstDay, toGranularity: .month)
        }

        monthKakeiboData.forEach {
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

    var dayItemDataObservable: Observable<[DayItemData]> {
        dayItemDataRelay.asObservable()
    }

    var cellDateDataObservable: Observable<[[CellDateKakeiboData]]> {
        cellDateDataRelay.asObservable()
    }

    var headerDateDataObservable: Observable<[HeaderDateKakeiboData]> {
        headerDateDataRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        calendarDate.navigationTitle.asDriver(onErrorDriveWith: .empty())
    }

    var incomeText: Driver<String> {
        incomeTextRelay.asDriver()
    }

    var expenseText: Driver<String> {
        expenseTextRelay.asDriver()
    }

    var balanceTxet: Driver<String> {
        balanceTextRelay.asDriver()
    }

    //    var isAnimatedIndicator: Driver<Bool> {
    //        isAnimatedIndicatorRelay.asDriver()
    //    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapInputBarButton(didHighlightItem indexPath: IndexPath) {
        if indexPath.isEmpty {
            eventRelay.accept(.presentAdd(Date()))
        } else {
            let dayItemDataArray = dayItemDataRelay.value
            let date = dayItemDataArray[indexPath.row].date
            eventRelay.accept(.presentAdd(date))
        }
    }

    func didActionNextMonth() {
        calendarDate.nextMonth()
    }

    func didActionLastMonth() {
        calendarDate.lastMonth()
    }

    func didSelectRowAt(index: IndexPath) {
        let cellDateData = cellDateDataRelay.value[index.section][index.row]
        let headerDateData = headerDateDataRelay.value[index.section]
        // categoryData.idをcategoryIdに変換
        let categoryId: CategoryId
        switch cellDateData.balance {
        case .income(_):
            categoryId = CategoryId.income(cellDateData.categoryData.id)
        case .expense(_):
            categoryId = CategoryId.expense(cellDateData.categoryData.id)
        }
        let kakeiboData = KakeiboData(
            date: headerDateData.date,
            categoryId: categoryId,
            balance: cellDateData.balance,
            memo: cellDateData.memo)
        eventRelay.accept(.presentEdit(kakeiboData))
    }

    /* tableViewのcellDateDataとheaderDateDataからKakeiboDataを作成しindexを求める。
     求めたindexをmodel.deleateDataの引数に入れてデータを削除する*/
    func didDeleateCell(index: IndexPath) {
        let cellDateData = cellDateDataRelay.value[index.section][index.row]
        let headerDateData = headerDateDataRelay.value[index.section]
        // categoryData.idをcategoryIdに変換
        let categoryId: CategoryId
        switch cellDateData.balance {
        case .income(_):
            categoryId = CategoryId.income(cellDateData.categoryData.id)
        case .expense(_):
            categoryId = CategoryId.expense(cellDateData.categoryData.id)
        }
        let kakeiboData = KakeiboData(
            date: headerDateData.date,
            categoryId: categoryId,
            balance: cellDateData.balance,
            memo: cellDateData.memo)
        if let firstIndex = kakeiboDataArray.firstIndex(where: { $0 == kakeiboData }) {
            model.deleateData(index: firstIndex)
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
