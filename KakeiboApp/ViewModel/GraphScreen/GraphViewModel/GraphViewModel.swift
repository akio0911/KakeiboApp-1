//
//  GraphViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import RxSwift
import RxCocoa

protocol GraphViewModelInput {
    func didTapNextBarButton()
    func didTapLastBarButton()
    func didSelectRowAt(index: IndexPath)
    func didChangeSegmentIndex(index: Int)
}

protocol GraphViewModelOutput {
    var graphData: Observable<[GraphData]> { get }
    var navigationTitle: Driver<String> { get }
    var totalBalance: Driver<Int> { get }
    var event: Driver<GraphViewModel.Event> { get }
}

protocol GraphViewModelType {
    var inputs: GraphViewModelInput { get }
    var outputs: GraphViewModelOutput { get }
}

final class GraphViewModel: GraphViewModelInput, GraphViewModelOutput {

    enum Event {
        case presentCategoryVC(CategoryData)
    }

    private let calendarDate: CalendarDateProtocol
    private var monthDateArray: [Date] = [] // 月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private var balanceSegmentIndex: Int = 0
    private var expenseCategoryDataArray: [CategoryData] {
        let categoryDataRepository: CategoryDataRepositoryProtocol = CategoryDataRepository()
        let expenseCategoryDataArray = categoryDataRepository.loadExpenseCategoryData()
        return expenseCategoryDataArray
    }
    private var incomeCategoryDataArray: [CategoryData] {
        let categoryDataRepository: CategoryDataRepositoryProtocol = CategoryDataRepository()
        let incomeCategoryDataArray = categoryDataRepository.loadIncomeCategoryData()
        return incomeCategoryDataArray
    }
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let graphDataArrayRelay = BehaviorRelay<[GraphData]>(value: [])
    private let totalBalanceRelay = BehaviorRelay<Int>(value: 0)
    private let eventRelay = PublishRelay<Event>()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         model: KakeiboModelProtocol = ModelLocator.shared.model) {
        self.calendarDate = calendarDate
        self.model = model
        setupBinding()
    }

    private func setupBinding() {
        calendarDate.monthDate
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.monthDateArray = dateArray
                self.acceptGraphData()
                self.acceptTotalBalance()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptGraphData()
                self.acceptTotalBalance()
            })
            .disposed(by: disposeBag)
    }

    private func acceptGraphData() {
        var graphDataArray: [GraphData] = []
        let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        switch balanceSegmentIndex {
        case 0:
            expenseCategoryDataArray.forEach {
                let expenseCategoryId = $0.id
                let categoryFilterData = dateFilterData.filter {
                    switch $0.categoryId {
                    case .income(_):
                        return false
                    case .expense(let categoryId):
                        return categoryId == expenseCategoryId
                    }
                }
                if !categoryFilterData.isEmpty {
                    let totalExpense = categoryFilterData.reduce(0) { $0 + $1.balance.fetchValue }
                    graphDataArray.append(
                        GraphData(categoryData: $0, totalBalance: totalExpense)
                    )
                }
            }
        case 1:
            incomeCategoryDataArray.forEach {
                let incomeCategoryId = $0.id
                let categoryFilterData = dateFilterData.filter {
                    switch $0.categoryId {
                    case .income(let categoryId):
                        return categoryId == incomeCategoryId
                    case .expense(_):
                        return false
                    }
                }
                if !categoryFilterData.isEmpty {
                    let totalIncome = categoryFilterData.reduce(0) { $0 + $1.balance.fetchValue }
                    graphDataArray.append(
                        GraphData(categoryData: $0, totalBalance: totalIncome)
                    )
                }
            }
        default:
            fatalError("想定していないsegmentIndex")
        }
        graphDataArrayRelay.accept(graphDataArray)
    }

    private func acceptTotalBalance() {
        let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        switch balanceSegmentIndex {
        case 0:
            let totalExpense = dateFilterData.filter {
                switch $0.balance {
                case .income(_): return false
                case .expense(_): return true
                }
            }
            .reduce(0) { $0 + $1.balance.fetchValue }
            totalBalanceRelay.accept(totalExpense)
        case 1:
            let totalIncome = dateFilterData.filter {
                switch $0.balance {
                case .income(_): return true
                case .expense(_): return false
                }
            }
            .reduce(0) { $0 + $1.balance.fetchValue }
            totalBalanceRelay.accept(totalIncome)
        default:
            fatalError("想定していないbalanceSegmentIndex")
        }
    }

    var graphData: Observable<[GraphData]> {
        graphDataArrayRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        calendarDate.navigationTitle.asDriver(onErrorDriveWith: .empty())
    }

    var totalBalance: Driver<Int> {
        totalBalanceRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapNextBarButton() {
        calendarDate.nextMonth()
    }

    func didTapLastBarButton() {
        calendarDate.lastMonth()
    }

    func didSelectRowAt(index: IndexPath) {
        let graphDataArray = graphDataArrayRelay.value
        eventRelay.accept(.presentCategoryVC(graphDataArray[index.row].categoryData))
    }

    func didChangeSegmentIndex(index: Int) {
        balanceSegmentIndex = index
        acceptGraphData()
        acceptTotalBalance()
    }
}

// MARK: - GraphViewModelType
extension GraphViewModel: GraphViewModelType {
    var inputs: GraphViewModelInput {
        return self
    }

    var outputs: GraphViewModelOutput {
        return self
    }
}
