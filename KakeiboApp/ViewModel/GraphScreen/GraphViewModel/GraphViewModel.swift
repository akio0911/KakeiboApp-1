//
//  GraphViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import RxSwift
import RxCocoa

protocol GraphViewModelInput {
    func didActionNextMonth()
    func didActionLastMonth()
    func didSelectRowAt(index: IndexPath)
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
        case presentCategoryVC(CategoryData)
    }

    private let calendarDate: CalendarDateProtocol
    private let model: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private var balanceSegmentIndex: Int = 0
    private let disposeBag = DisposeBag()
    private let graphDataArrayRelay = BehaviorRelay<[GraphData]>(value: [])
    private let eventRelay = PublishRelay<Event>()

    init(calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         model: KakeiboModelProtocol = ModelLocator.shared.model,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel) {
        self.calendarDate = calendarDate
        self.model = model
        self.categoryModel = categoryModel
        setupBinding()
    }
    private var monthDateArray: [Date] = [] // 月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private var incomeCategoryDataArray: [CategoryData] = []
    private var expenseCategoryDataArray: [CategoryData] = []

    private func setupBinding() {
        calendarDate.monthDate
            .subscribe(onNext: { dateArray in
                self.monthDateArray = dateArray
                self.acceptGraphData()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { kakeiboDataArray in
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptGraphData()
            })
            .disposed(by: disposeBag)

        categoryModel.incomeCategoryData
            .subscribe(onNext: { incomeCategoryDataArray in
                self.incomeCategoryDataArray = incomeCategoryDataArray
                self.acceptGraphData()
            })
            .disposed(by: disposeBag)

        categoryModel.expenseCategoryData
            .subscribe(onNext: { expenseCategoryDataArray in
                self.expenseCategoryDataArray = expenseCategoryDataArray
                self.acceptGraphData()
            })
            .disposed(by: disposeBag)
    }

    private func acceptGraphData() {
        var graphDataArray: [GraphData] = []
        let firstDay = monthDateArray[0] // 月の初日(ついたち)
        let monthData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        switch balanceSegmentIndex {
        case 0:
            expenseCategoryDataArray.forEach {
                let expenseCategoryId = $0.id
                let categoryFilterData = monthData.filter {
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
                let categoryFilterData = monthData.filter {
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
        calendarDate.navigationTitle.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didActionNextMonth() {
        calendarDate.nextMonth()
    }

    func didActionLastMonth() {
        calendarDate.lastMonth()
    }

    func didSelectRowAt(index: IndexPath) {
        let graphDataArray = graphDataArrayRelay.value
        eventRelay.accept(.presentCategoryVC(graphDataArray[index.row].categoryData))
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
