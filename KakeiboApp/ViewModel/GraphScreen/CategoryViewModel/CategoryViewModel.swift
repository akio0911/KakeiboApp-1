//
//  CategoryViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/18.
//

import RxSwift
import RxCocoa

protocol CategoryViewModelInput {
}

protocol CategoryViewModelOutput {
    var cellDateDataObservable: Observable<[[CellDateCategoryData]]> { get }
    var headerDateDataObservable: Observable<[HeaderDateCategoryData]> { get }
    var navigationTitle: Driver<String> { get }
}

protocol CategoryViewModelType {
    var inputs: CategoryViewModelInput { get }
    var outputs: CategoryViewModelOutput { get }
}

final class CategoryViewModel: CategoryViewModelInput, CategoryViewModelOutput {

    private let categoryData: CategoryData
    private var monthDataArray: [Date] = [] // 月の日付
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private let calendarDate: CalendarDateProtocol
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let cellDateDataRelay =  BehaviorRelay<[[CellDateCategoryData]]>(value: [])
    private let headerDateDataRelay =
        BehaviorRelay<[HeaderDateCategoryData]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")

    init(categoryData: CategoryData,
         calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         model: KakeiboModelProtocol = ModelLocator.shared.model) {
        self.categoryData = categoryData
        self.calendarDate = calendarDate
        self.model = model
        acceptNavigationTitle()
        setupBinding()
    }

    private func acceptNavigationTitle() {
        navigationTitleRelay.accept(categoryData.name)
    }

    private func setupBinding() {
        calendarDate.monthDate
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.monthDataArray = dateArray
                self.acceptTableViewData()
            })
            .disposed(by: disposeBag)

        model.dataObservable
            .subscribe(onNext: { [weak self] dateArray in
                guard let self = self else { return }
                self.kakeiboDataArray = dateArray
                self.acceptTableViewData()
            })
            .disposed(by: disposeBag)
    }

    private func acceptTableViewData() {
        guard !monthDataArray.isEmpty else { return }
        var cellDataArray: [[CellDateCategoryData]] = []
        var headerDataArray: [HeaderDateCategoryData] = []
        let firstDay = monthDataArray[0] // 月の初日(ついたち)
        let monthFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0.date, toGranularity: .month)
        }

        let categoryFilterData = monthFilterData.filter {
            switch $0.categoryId {
            case .income(let categoryId):
                return categoryId == categoryData.id
            case .expense(let categoryId):
                return categoryId == categoryData.id
            }
        }
        monthDataArray.forEach {
            var cellData: [CellDateCategoryData] = []
            let date = $0
            let dateFilterData = categoryFilterData.filter { date == $0.date }
            if !dateFilterData.isEmpty {
                dateFilterData.forEach {
                    cellData.append(
                        CellDateCategoryData(balance: $0.balance, memo: $0.memo)
                    )
                }
                let totalBalance = dateFilterData.reduce(0) { $0 + $1.balance.fetchValue }
                cellDataArray.append(cellData)
                headerDataArray.append(
                    HeaderDateCategoryData(date: date, totalBalance: totalBalance)
                )
            }
        }
        cellDateDataRelay.accept(cellDataArray)
        headerDateDataRelay.accept(headerDataArray)
    }

    var cellDateDataObservable: Observable<[[CellDateCategoryData]]> {
        cellDateDataRelay.asObservable()
    }

    var headerDateDataObservable: Observable<[HeaderDateCategoryData]> {
        headerDateDataRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver(onErrorDriveWith: .empty())
    }
}

extension CategoryViewModel: CategoryViewModelType {
    var inputs: CategoryViewModelInput {
        return self
    }

    var outputs: CategoryViewModelOutput {
        return self
    }
}
