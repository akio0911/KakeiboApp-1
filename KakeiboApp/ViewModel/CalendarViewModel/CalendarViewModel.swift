//
//  CalendarViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxCocoa

protocol CalendarViewModelInput {
    func didTapInputBarButton()
    func didTapNextBarButton()
    func didTapLastBarButton()
    func didSelectRowAt()
}

protocol CalendarViewModelOutput {
    var collectionViewDataObservable: Observable<[SecondSectionItemData]> { get }
    var tableViewCellDataObservable: Observable<[[TableViewCellData]]> { get }
    var tableViewHeaderObservable: Observable<[TableViewHeaderData]> { get }
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
        case presentAdd
        case presentEdit(Int)
    }

    private let calendarDate: CalendarDateProtocol
    private var collectionViewDateArray: [Date] = [] // カレンダーに表示する日付
    private var tableViewDateArray: [Date] = [] // titleに表示されてる月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let collectionViewDataRelay = BehaviorRelay<[SecondSectionItemData]>(value: [])
    private let tableViewCellDataRelay = BehaviorRelay<[[TableViewCellData]]>(value: [])
    private let tableViewHeaderDataRelay = BehaviorRelay<[TableViewHeaderData]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let incomeTextRelay = BehaviorRelay<String>(value: "")
    private let expenseTextRelay = BehaviorRelay<String>(value: "")
    private let balanceTextRelay = BehaviorRelay<String>(value: "")
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
                self.acceptSecondSectionCellData()
            })
            .disposed(by: disposeBag)

        calendarDate.tableViewDateArray
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.tableViewDateArray = dateArray
                self.acceptTableViewData()
                self.acceptSetLabelEvent()
            })
            .disposed(by: disposeBag)

        calendarDate.navigationTitle
            .bind(to: navigationTitleRelay)
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptSecondSectionCellData()
                self.acceptTableViewData()
                self.acceptSetLabelEvent()
            })
            .disposed(by: disposeBag)
    }

    private func acceptSecondSectionCellData() {
        var secondSectionCellDataArray: [SecondSectionItemData] = []

        self.collectionViewDateArray.forEach {
            let date = $0
            let totalBalance = kakeiboDataArray
                .filter { $0.date == date }
                .reduce(0) { $0 + ($1.balance!.income - $1.balance!.expense) }
            let secondSectionCellData = SecondSectionItemData(
                date: date, totalBalance: totalBalance
            )
            secondSectionCellDataArray.append(secondSectionCellData)
        }
        self.collectionViewDataRelay.accept(secondSectionCellDataArray)
    }

    private func acceptTableViewData() {
        var tableViewCellDataArray: [[TableViewCellData]] = [[]]
        var tableViewHeaderDataArray: [TableViewHeaderData] = []

        self.tableViewDateArray.forEach {
            let date = $0
            var tableViewCellData: [TableViewCellData] = []
            let dateFilterData = kakeiboDataArray
                .filter { $0.date == date }

            if !dateFilterData.isEmpty {
                dateFilterData.forEach {
                    tableViewCellData.append(
                        TableViewCellData(
                            category: $0.category, balance: $0.balance!, memo: $0.memo
                        )
                    )
                }
                tableViewCellDataArray.append(tableViewCellData)

                let totalBalance = dateFilterData
                    .reduce(0) { $0 + ($1.balance!.income - $1.balance!.expense) }
                tableViewHeaderDataArray.append(
                    TableViewHeaderData(date: date, totalBalance: totalBalance)
                )
            }
        }

        self.tableViewCellDataRelay.accept(tableViewCellDataArray.filter { !$0.isEmpty })
        self.tableViewHeaderDataRelay.accept(tableViewHeaderDataArray)
    }

    private func acceptSetLabelEvent() {
        let firstDay = self.tableViewDateArray[0] // titleに表示されている月の1日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        let totalIncome = dateFilterData
            .filter { $0.balance!.income != 0 }
            .reduce(0) { $0 + $1.balance!.income }
        incomeTextRelay.accept(String(totalIncome))

        let totalExpense = dateFilterData
            .filter { $0.balance!.expense != 0 }
            .reduce(0) { $0 - $1.balance!.expense }
        expenseTextRelay.accept(String(totalExpense))

        let totalBalance = totalIncome + totalExpense
        balanceTextRelay.accept(String(totalBalance))
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

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver()
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

    func didTapInputBarButton() {
        eventRelay.accept(.presentAdd)
    }

    func didTapNextBarButton() {
        calendarDate.nextMonth()
    }

    func didTapLastBarButton() {
        calendarDate.lastMonth()
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
