//
//  GraphViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import RxSwift
import RxCocoa

protocol GraphViewModelInput {
    func onViewDidAppear()
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(indexPath: IndexPath)
    func didChangeSegmentIndex(index: Int)
    func didTapTermButton()
}

protocol GraphViewModelOutput {
    var graphData: Observable<([GraphData], SegmentIndex: Int, animated: Bool)> { get }
    var dateTitle: Driver<String> { get }
    var leftBarButtonTitle: Driver<String> { get }
    var event: Driver<GraphViewModel.Event> { get }
}

protocol GraphViewModelType {
    var inputs: GraphViewModelInput { get }
    var outputs: GraphViewModelOutput { get }
}

final class GraphViewModel: GraphViewModelInput, GraphViewModelOutput {
    enum Event {
        case presentCategoryVC(categoryData: CategoryData, displayDate: Date)
        case setTerm(
            selectedCardIndexPath: IndexPath,
            selectedSegmentIndex: Int,
            cardCount: Int
        )
    }

    enum Term {
        case yearly
        case monthly
    }

    private let calendarDate: CalendarDateProtocol
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private var balanceSegmentIndex: Int = 0
    private let disposeBag = DisposeBag()
    private let graphDataArrayRelay = BehaviorRelay<([GraphData], SegmentIndex: Int, animated: Bool)>(value: ([], SegmentIndex: 0, animated: true))
    private let dateTitleRelay =
    BehaviorRelay<String>(value: DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))
    private let leftBarButtonTitleRelay = PublishRelay<String>()
    private let eventRelay = PublishRelay<Event>()
    private var displayDate = Date()
    fileprivate var term: Term = .monthly

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
                self?.acceptGraphData(animated: false)
            }
            .disposed(by: disposeBag)
    }

    private func acceptGraphData(animated: Bool) {
        var graphDataArray: [GraphData] = []
        let kakeiboData: [KakeiboData]
        switch term {
        case .yearly:
            kakeiboData = kakeiboModel.loadYearData(date: displayDate)
        case .monthly:
            kakeiboData = kakeiboModel.loadMonthData(date: displayDate)
        }
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
        graphDataArrayRelay.accept((graphDataArray, balanceSegmentIndex, animated))
    }

    var graphData: Observable<([GraphData], SegmentIndex: Int, animated: Bool)> {
        graphDataArrayRelay.asObservable()
    }

    var dateTitle: Driver<String> {
        dateTitleRelay.asDriver()
    }

    var leftBarButtonTitle: Driver<String> {
        leftBarButtonTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewDidAppear() {
        acceptGraphData(animated: false)
        switch term {
        case .yearly:
            dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年"))
            leftBarButtonTitleRelay.accept(R.string.localizable.yearly())
        case .monthly:
            dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
            leftBarButtonTitleRelay.accept(R.string.localizable.monthly())
        }
    }

    func didActionNextMonth() {
        switch term {
        case .yearly:
            if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .year, value: 1, to: displayDate) {
                self.displayDate = displayDate
                acceptGraphData(animated: true)
                dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年"))
            }
        case .monthly:
            if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: displayDate) {
                self.displayDate = displayDate
                acceptGraphData(animated: true)
                dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
            }
        }
    }

    func didActionLastMonth() {
        switch term {
        case .yearly:
            if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .year, value: -1, to: displayDate) {
                self.displayDate = displayDate
                acceptGraphData(animated: true)
                dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年"))
            }
        case .monthly:
            if let displayDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: -1, to: displayDate) {
                self.displayDate = displayDate
                acceptGraphData(animated: true)
                dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
            }
        }
    }

    func didSelectRowAt(indexPath: IndexPath) {
        let graphDataArray = graphDataArrayRelay.value
        eventRelay.accept(
            .presentCategoryVC(categoryData: graphDataArray.0[indexPath.row].categoryData, displayDate: displayDate)
        )
    }

    func didChangeSegmentIndex(index: Int) {
        balanceSegmentIndex = index
        acceptGraphData(animated: true)
    }

    func didTapTermButton() {
        term.toggle()
        acceptTerm()
        acceptGraphData(animated: true)
    }

    private func acceptTerm() {
        balanceSegmentIndex = 0
        displayDate = Date()
        switch term {
        case .yearly:
            dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年"))
            leftBarButtonTitleRelay.accept(R.string.localizable.yearly())
            eventRelay.accept(
                .setTerm(
                    selectedCardIndexPath: .init(row: 10, section: 0),
                    selectedSegmentIndex: balanceSegmentIndex,
                    cardCount: 20
                )
            )
            acceptGraphData(animated: false)
        case .monthly:
            dateTitleRelay.accept(DateUtility.stringFromDate(date: displayDate, format: "yyyy年MM月"))
            leftBarButtonTitleRelay.accept(R.string.localizable.monthly())
            eventRelay.accept(
                .setTerm(
                    selectedCardIndexPath: .init(row: 120, section: 0),
                    selectedSegmentIndex: balanceSegmentIndex,
                    cardCount: 240
                )
            )
            acceptGraphData(animated: false)
        }
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

// MARK: - TermExtension
extension GraphViewModel.Term {
    mutating func toggle() {
        switch self {
        case .yearly:
            self = .monthly
        case .monthly:
            self = .yearly
        }
    }
}
