//
//  CalendarViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxCocoa

protocol CalendarViewModelInput {
    func loadData()
    func didTapNextBarButton()
    func didTapLastBarButton()
    func didSelectRowAt()
}

protocol CalendarViewModelOutput {
    var collectionViewDataObservable: Observable<[SecondSectionItemData]> { get }
    var tableViewCellDataObservable: Observable<[[TableViewCellData]]> { get }
    var tableViewHeaderObservable: Observable<[TableViewHeaderData]> { get }
    var event: Driver<CalendarViewModel.Event> { get }
}

protocol CalendarViewModelType {
    var inputs: CalendarViewModelInput { get }
    var outputs: CalendarViewModelOutput { get }
}

final class CalendarViewModel: CalendarViewModelInput, CalendarViewModelOutput {
    enum Event {
        case setNavigationTitle(String)
        case setLabel([String : String])
    }

    private let calendarDate: CalendarDateProtocol
    private var collectionViewDateArray: [Date] = [] // カレンダーに表示する日付
    private var tableViewDateArray: [Date] = [] // titleに表示されてる月の日付
    private var navigationTitle = ""
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let collectionViewDataRelay = PublishRelay<[SecondSectionItemData]>()
    private let tableViewCellDataRelay = PublishRelay<[[TableViewCellData]]>()
    private let tableViewHeaderDataRelay = PublishRelay<[TableViewHeaderData]>()
    private let eventRelay = PublishRelay<Event>()

    init(calendarDate: CalendarDateProtocol = CalendarDate(),
        model: KakeiboModelProtocol = ModelLocator.shared.model) {
        self.calendarDate = calendarDate
        self.model = model
        setupBinding()
    }

    private func setupBinding() {
        calendarDate.collectionViewDateArray
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.collectionViewDateArray = dateArray
                print(dateArray)
            })
            .disposed(by: disposeBag)

        calendarDate.tableViewDateArray
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.tableViewDateArray = dateArray
                print(dateArray)
            })
            .disposed(by: disposeBag)


        calendarDate.navigationTitle
            .subscribe(onNext: { [weak self] navigationTitle in
                guard let self = self else { return }
                self.navigationTitle = navigationTitle
                print(navigationTitle)
            })
            .disposed(by: disposeBag)

        let dataObservable = model.dataObservable
            .skip(1) // 初期値がれるためスキップ
            .share()

        dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                var secondSectionCellDataArray: [SecondSectionItemData] = []

                self.collectionViewDateArray.forEach {
                    let date = $0
                    let totalBalance = kakeiboDataArray
                        .filter { $0.date == date }
                        .reduce(0) { $0 + $1.balance.signConversion }
                    let secondSectionCellData = SecondSectionItemData(
                        date: date, totalBalance: totalBalance
                    )
                    secondSectionCellDataArray.append(secondSectionCellData)
                }
                print(secondSectionCellDataArray)
                self.collectionViewDataRelay.accept(secondSectionCellDataArray)
            })
            .disposed(by: disposeBag)

        dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                var tableViewCellDataArray: [[TableViewCellData]] = [[]]
                var tableViewHeaderDataArray: [TableViewHeaderData] = []

                self.tableViewDateArray.forEach {
                    let date = $0
                    var tableViewCellData: [TableViewCellData] = []
                    let dateFilterData = kakeiboDataArray
                        .filter { $0.date == date }

                    dateFilterData.forEach {
                        tableViewCellData.append(
                            TableViewCellData(
                                category: $0.category, balance: $0.balance, memo: $0.memo
                            )
                        )
                    }
                    tableViewCellDataArray.append(tableViewCellData)

                    let totalBalance = dateFilterData
                        .reduce(0) { $0 + $1.balance.signConversion }
                    tableViewHeaderDataArray.append(
                        TableViewHeaderData(date: date, totalBalance: totalBalance)
                    )
                }
                
                self.tableViewCellDataRelay.accept(
                    tableViewCellDataArray.filter { !$0.isEmpty }
                )
                self.tableViewHeaderDataRelay.accept(tableViewHeaderDataArray)
            })
            .disposed(by: disposeBag)

        dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                let firstDay = self.tableViewDateArray[0] // titleに表示されている月の1日(ついたち)
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
                    .reduce(0) { $0 + $1.balance.signConversion }

                let totalExpense = dateFilterData
                    .filter {
                        switch $0.balance {
                        case .income(_): return false
                        case .expense(_): return true
                        }
                    }
                    .reduce(0) { $0 + $1.balance.signConversion }

                let totalBalance = dateFilterData
                    .reduce(0) { $0 + $1.balance.signConversion }

                let calendarLabel: [String : String] = [
                    CalendarLabel.IncomeLabel.rawValue : String(totalIncome),
                    CalendarLabel.ExpenseLabel.rawValue : String(totalExpense),
                    CalendarLabel.BalanceLabel.rawValue : String(totalBalance)
                ]
                self.eventRelay.accept(.setLabel(calendarLabel))
            })
            .disposed(by: disposeBag)
    }

    var collectionViewDataObservable: Observable<[SecondSectionItemData]> {
        collectionViewDataRelay.asObservable()
    }

    var tableViewCellDataObservable: Observable<[[TableViewCellData]]> {
        tableViewCellDataRelay.asObservable()
    }

    var tableViewHeaderObservable: Observable<[TableViewHeaderData]> {
        tableViewHeaderDataRelay.asObservable()
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func loadData() {
        // TODO: realmSwiftからデータをload()
        model.loadData(data: [])
        eventRelay.accept(.setNavigationTitle(navigationTitle))
    }

    func didTapNextBarButton() {
        calendarDate.nextMonth()
        // TODO: realmSwiftからデータをload()
        model.loadData(data: [])
        eventRelay.accept(.setNavigationTitle(navigationTitle))
    }

    func didTapLastBarButton() {
        calendarDate.lastMonth()
        // TODO: realmSwiftからデータをload()
        model.loadData(data: [])
        eventRelay.accept(.setNavigationTitle(navigationTitle))
    }

    func didSelectRowAt() {
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

// MARK: - extension Balance(signConversion)
extension Balance {
    var signConversion: Int {
        switch self {
        case .income(let income):
            return income
        case .expense(let expense):
            return -expense
        }
    }
}
