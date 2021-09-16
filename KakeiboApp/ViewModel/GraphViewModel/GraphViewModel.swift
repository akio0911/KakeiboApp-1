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
}

protocol GraphViewModelType {
    var inputs: GraphViewModelInput { get }
    var outputs: GraphViewModelOutput { get }
}

final class GraphViewModel: GraphViewModelInput, GraphViewModelOutput {

    private let calendarDate: CalendarDateProtocol
    private var monthDateArray: [Date] = [] // 月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private var balanceSegmentIndex: Int = 0
    private let expenseCategoryArray: [Category.Expense] = Category.Expense.allCases
    private let incomeCategoryArray: [Category.Income] = Category.Income.allCases
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let graphDataRelay = BehaviorRelay<[GraphData]>(value: [])

    init(calendarDate: CalendarDateProtocol = CalendarDateLocator.shared.calendarDate,
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
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptGraphData()
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
            expenseCategoryArray.forEach {
                let expenseCategory = $0
                let categoryFilterData = dateFilterData.filter {
                    switch $0.category {
                    case .income(_):
                        return false
                    case .expense(let category):
                        return category == expenseCategory
                    }
                }
                if !categoryFilterData.isEmpty {
                    let totalExpense = categoryFilterData.reduce(0) { $0 + $1.balance.fetchValue }
                    graphDataArray.append(
                        GraphData(category: Category.expense(expenseCategory), totalBalance: totalExpense)
                    )
                }
            }
        case 1:
            incomeCategoryArray.forEach {
                let incomeCategory = $0
                let categoryFilterData = dateFilterData.filter {
                    switch $0.category {
                    case .income(let category):
                        return category == incomeCategory
                    case .expense(_):
                        return false
                    }
                }
                if !categoryFilterData.isEmpty {
                    let totalIncome = categoryFilterData.reduce(0) { $0 + $1.balance.fetchValue }
                    graphDataArray.append(
                        GraphData(category: Category.income(incomeCategory), totalBalance: totalIncome)
                    )
                }
            }
        default:
            fatalError("想定していないsegmentIndex")
        }
        graphDataRelay.accept(graphDataArray)
    }

    var graphData: Observable<[GraphData]> {
        graphDataRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        calendarDate.navigationTitle.asDriver(onErrorDriveWith: .empty())
    }

    func didTapNextBarButton() {
        calendarDate.nextMonth()
    }

    func didTapLastBarButton() {
        calendarDate.lastMonth()
    }

    func didSelectRowAt(index: IndexPath) {
    }

    func didChangeSegmentIndex(index: Int) {
        balanceSegmentIndex = index
        acceptGraphData()
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
