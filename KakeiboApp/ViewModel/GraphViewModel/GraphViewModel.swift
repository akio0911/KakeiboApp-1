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
}

protocol GraphViewModelOutput {
    var cellCategoryDataObservable: Observable<[CellCategoryKakeiboData]> { get }
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
    private let categoryArray: [Category] = Category.allCases
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let cellCategoryDataRelay = BehaviorRelay<[CellCategoryKakeiboData]>(value: [])

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
                self.acceptCellCategoryData()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
                self.acceptCellCategoryData()
            })
            .disposed(by: disposeBag)
    }

    private func acceptCellCategoryData() {
        var cellCategoryData: [CellCategoryKakeiboData] = []
        let firstDay = self.monthDateArray[0] // 月の初日(ついたち)
        let dateFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        categoryArray.forEach {
            let category = $0
            let totalBalance = dateFilterData
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.balance.signConversion }
            cellCategoryData.append(
                CellCategoryKakeiboData(category: category, totalBalance: totalBalance)
            )
        }
        cellCategoryDataRelay.accept(cellCategoryData)
    }

    var cellCategoryDataObservable: Observable<[CellCategoryKakeiboData]> {
        cellCategoryDataRelay.asObservable()
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
