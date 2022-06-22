//
//  GraphViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import RxSwift
import RxCocoa

protocol GraphViewModelInput {
    func onViewWillAppear()
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(indexPath: IndexPath)
    func didChangeSegmentIndex(index: Int)
}

protocol GraphViewModelOutput {
    var graphData: Observable<[GraphData]> { get }
    var navigationTitle: Driver<String> { get }
    var event: Driver<GraphViewModel.Event> { get }
}

protocol GraphViewModelType {
    var inputs: GraphViewModelInput { get }
    var outputs: GraphViewModelOutput { get }
}

final class GraphViewModel: GraphViewModelInput, GraphViewModelOutput {
    enum Event {
        case presentCategoryVC(categoryData: CategoryData, displayDate: Date)
    }

    private let calendarDate: CalendarDateProtocol
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private var balanceSegmentIndex: Int = 0
    private let disposeBag = DisposeBag()
    private let graphDataArrayRelay = BehaviorRelay<[GraphData]>(value: [])
    private let navigationTitleRelay =
    BehaviorRelay<String>(value: DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))
    private let eventRelay = PublishRelay<Event>()
    private var displayDate = Date()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel) {
        self.calendarDate = calendarDate
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        setupBinding()
    }

    private func setupBinding() {
        EventBus.setupData.asObservable()
            .subscribe { [weak self] _ in
                self?.acceptGraphData()
            }
            .disposed(by: disposeBag)
    }

    private func acceptGraphData() {
        var graphDataArray: [GraphData] = []

        let kakeiboData = kakeiboModel.loadMonthData(date: displayDate)
        switch balanceSegmentIndex {
        case 0:
            // 支出
            categoryModel.expenseCategoryDataArray.forEach {
                let expenseCategoryId = $0.id
                let categoryFilterData = kakeiboData.filter {
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
            // 収入
            categoryModel.incomeCategoryDataArray.forEach {
                let incomeCategoryId = $0.id
                let categoryFilterData = kakeiboData.filter {
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

    var graphData: Observable<[GraphData]> {
        graphDataArrayRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver()
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewWillAppear() {
        acceptGraphData()
    }

    func didActionNextMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: displayDate) {
            self.displayDate = displayDate
            acceptGraphData()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didActionLastMonth() {
        if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: -1, to: displayDate) {
            self.displayDate = displayDate
            acceptGraphData()
            navigationTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
        }
    }

    func didSelectRowAt(indexPath: IndexPath) {
        let graphDataArray = graphDataArrayRelay.value
        eventRelay.accept(
            .presentCategoryVC(categoryData: graphDataArray[indexPath.row].categoryData, displayDate: displayDate)
        )
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
