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
    func didTapNextBarButton()
    func didTapLastBarButton()
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

    private let calendarDate: CalendarDateProtocol
    private var calendarDateArray: [Date] = [] // カレンダーに表示する日付
    private var monthDateArray: [Date] = [] // 月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let dayItemDataRelay = BehaviorRelay<[DayItemData]>(value: [])
    private let cellDateDataRelay = BehaviorRelay<[[CellDateKakeiboData]]>(value: [])
    private let headerDateDataRelay = BehaviorRelay<[HeaderDateKakeiboData]>(value: [])
    private let incomeTextRelay = BehaviorRelay<String>(value: "")
    private let expenseTextRelay = BehaviorRelay<String>(value: "")
    private let balanceTextRelay = BehaviorRelay<String>(value: "")
    private let eventRelay = PublishRelay<Event>()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         model: KakeiboModelProtocol = ModelLocator.shared.model) {
        self.calendarDate = calendarDate
        self.model = model
        setupBinding()
    }

    private func setupBinding() {
        calendarDate.calendarDate
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.calendarDateArray = dateArray
            })
            .disposed(by: disposeBag)

        calendarDate.monthDate
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.monthDateArray = dateArray
                self.acceptDayItemData()
                self.acceptTableViewData()
                self.acceptSetLabelEvent()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptDayItemData()
                self.acceptTableViewData()
                self.acceptSetLabelEvent()
            })
            .disposed(by: disposeBag)
    }

    private func acceptDayItemData() {
        if !monthDateArray.isEmpty {
            var dayItemDataArray: [DayItemData] = []
            let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
            self.calendarDateArray.forEach {
                let date = $0
                let totalBalance = kakeiboDataArray
                    .filter { $0.date == date }
                    .reduce(0) { $0 + $1.balance.fetchValueSigned }
                let dayItemData = DayItemData(
                    date: date, totalBalance: totalBalance, firstDay: firstDay
                )
                dayItemDataArray.append(dayItemData)
            }
            self.dayItemDataRelay.accept(dayItemDataArray)
        }
    }

    private func acceptTableViewData() {
        var cellDataArray: [[CellDateKakeiboData]] = [[]]
        var headerDataArray: [HeaderDateKakeiboData] = []

        self.monthDateArray.forEach {
            let date = $0
            var cellData: [CellDateKakeiboData] = []
            let dateFilterData = kakeiboDataArray
                .filter { $0.date == date }

            if !dateFilterData.isEmpty {
                dateFilterData.forEach {
                    cellData.append(
                        CellDateKakeiboData(
                            categoryId: $0.categoryId, balance: $0.balance, memo: $0.memo
                        )
                    )
                }
                cellDataArray.append(cellData)

                let totalBalance = dateFilterData
                    .reduce(0) { $0 + $1.balance.fetchValueSigned }
                headerDataArray.append(
                    HeaderDateKakeiboData(date: date, totalBalance: totalBalance)
                )
            }
        }

        self.cellDateDataRelay.accept(cellDataArray.filter { !$0.isEmpty })
        self.headerDateDataRelay.accept(headerDataArray)
    }

    private func acceptSetLabelEvent() {
        let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        let totalIncome = dateFilterData
            .filter {
                switch $0.balance {
                case .income(_): return true
                case .expense(_): return false
                }
            }
            .reduce(0) { $0 + $1.balance.fetchValue }
        incomeTextRelay.accept(NumberFormatterUtility.changeToCurrencyNotation(from: totalIncome) ?? "0円")

        let totalExpense = dateFilterData
            .filter {
                switch $0.balance {
                case .income(_): return false
                case .expense(_): return true
                }
            }
            .reduce(0) { $0 + $1.balance.fetchValue }
        expenseTextRelay.accept(NumberFormatterUtility.changeToCurrencyNotation(from: totalExpense) ?? "0円")

        let totalBalance = totalIncome - totalExpense
        balanceTextRelay.accept(NumberFormatterUtility.changeToCurrencyNotation(from: totalBalance) ?? "0円")
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

    func didTapNextBarButton() {
        calendarDate.nextMonth()
    }

    func didTapLastBarButton() {
        calendarDate.lastMonth()
    }

    func didSelectRowAt(index: IndexPath) {
        let cellDateData = cellDateDataRelay.value[index.section][index.row]
        let headerDateData = headerDateDataRelay.value[index.section]
        let kakeiboData = KakeiboData(
            date: headerDateData.date,
            categoryId: cellDateData.categoryId,
            balance: cellDateData.balance,
            memo: cellDateData.memo)
        eventRelay.accept(.presentEdit(kakeiboData))
    }

    /* tableViewのcellDateDataとheaderDateDataからKakeiboDataを作成しindexを求める。
     求めたindexをmodel.deleateDataの引数に入れてデータを削除する*/
    func didDeleateCell(index: IndexPath) {
        let cellDateData = cellDateDataRelay.value[index.section][index.row]
        let headerDateData = headerDateDataRelay.value[index.section]
        let kakeiboData = KakeiboData(
            date: headerDateData.date,
            categoryId: cellDateData.categoryId,
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
