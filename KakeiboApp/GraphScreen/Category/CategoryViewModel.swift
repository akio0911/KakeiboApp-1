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
    private var kakeiboDataArray: [KakeiboData] = [] // 保存データ
    private let calendarDate: CalendarDateProtocol
    private let kakeiboModel: KakeiboModelProtocol
    private let displayDate: Date
    private let disposeBag = DisposeBag()
    private let cellDateDataRelay =  BehaviorRelay<[[CellDateCategoryData]]>(value: [])
    private let headerDateDataRelay = BehaviorRelay<[HeaderDateCategoryData]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))

    init(categoryData: CategoryData,
         calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         displayDate: Date) {
        self.categoryData = categoryData
        self.calendarDate = calendarDate
        self.kakeiboModel = kakeiboModel
        self.displayDate = displayDate
        acceptNavigationTitle()
        setupBinding()
    }

    private func acceptNavigationTitle() {
        navigationTitleRelay.accept(categoryData.name)
    }

    private func setupBinding() {
        kakeiboModel.dataObservable
            .subscribe(onNext: { [weak self] kakeiboData in
                guard let strongSelf = self else { return }
                strongSelf.kakeiboDataArray = kakeiboData
                strongSelf.acceptTableViewData()
            })
            .disposed(by: disposeBag)
    }

    private func acceptTableViewData() {
        guard let year = Int(DateUtility.stringFromDate(date: displayDate, format: "yyyy")),
              let month = Int(DateUtility.stringFromDate(date: displayDate, format: "MM")) else {
            return
        }
        var cellDataArray: [[CellDateCategoryData]] = []
        var headerDataArray: [HeaderDateCategoryData] = []
        let monthFilterData = kakeiboDataArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(displayDate, equalTo: $0.date, toGranularity: .year)
            && Calendar(identifier: .gregorian)
                .isDate(displayDate, equalTo: $0.date, toGranularity: .month)
        }

        let categoryFilterData = monthFilterData.filter {
            switch $0.categoryId {
            case .income(let categoryId):
                return categoryId == categoryData.id
            case .expense(let categoryId):
                return categoryId == categoryData.id
            }
        }
        let monthDateArray = calendarDate.loadCalendarDate(year: year, month: month, isContainOtherMonth: false)
        monthDateArray.forEach {
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
