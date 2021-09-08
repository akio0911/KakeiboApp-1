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
    var cellCategoryDataObservable: Observable<[CellCategoryKakeiboData]> { get }
    var graphData: Driver<[GraphData]> { get }
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
    private let categoryArray: [Category] = Category.allCases
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let cellCategoryDataRelay = BehaviorRelay<[CellCategoryKakeiboData]>(value: [])
    private let graphDataRelay = PublishRelay<[GraphData]>()

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
        var cellCategoryData: [CellCategoryKakeiboData] = []
        var graphData: [GraphData] = []
        let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        categoryArray.forEach {
            let category = $0
            let categoryFilterData = dateFilterData
                .filter { $0.category == category }
            let totalIncome = categoryFilterData
                .filter {
                    switch $0.balance {
                    case .income(_): return true
                    case .expense(_): return false
                    }
                }
                .reduce(0) { $0 + $1.balance.signConversion }
            let totalExpense = categoryFilterData
                .filter {
                    switch $0.balance {
                    case .income(_): return false
                    case .expense(_): return true
                    }
                }
                .reduce(0) { $0 + $1.balance.signConversion }
            switch balanceSegmentIndex {
            case 0:
                cellCategoryData.append(
                    CellCategoryKakeiboData(
                        category: category, totalBalance: totalExpense
                    )
                )
                graphData.append(
                    GraphData(category: category, totalBalance: totalExpense)
                )
            case 1:
                cellCategoryData.append(
                    CellCategoryKakeiboData(
                        category: category, totalBalance: totalIncome
                    )
                )
                graphData.append(
                    GraphData(category: category, totalBalance: totalIncome)
                )
            default:
                fatalError("想定していないsegmentIndex")
            }
        }
        cellCategoryDataRelay.accept(cellCategoryData)
        graphDataRelay.accept(graphData)
    }

    var cellCategoryDataObservable: Observable<[CellCategoryKakeiboData]> {
        cellCategoryDataRelay.asObservable()
    }

    var graphData: Driver<[GraphData]> {
        graphDataRelay.asDriver(onErrorDriveWith: .empty())
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
