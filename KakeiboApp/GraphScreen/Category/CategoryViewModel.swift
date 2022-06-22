//
//  CategoryViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/18.
//

import RxSwift
import RxCocoa

protocol CategoryViewModelInput {
    func onViewDidLoad()
}

protocol CategoryViewModelOutput {
    var categoryItemObservable: Observable<[CategoryItem]> { get }
    var navigationTitle: Driver<String> { get }
}

protocol CategoryViewModelType {
    var inputs: CategoryViewModelInput { get }
    var outputs: CategoryViewModelOutput { get }
}

final class CategoryViewModel: CategoryViewModelInput, CategoryViewModelOutput {
    private let categoryData: CategoryData
    private let calendarDate: CalendarDateProtocol
    private let kakeiboModel: KakeiboModelProtocol
    private let displayDate: Date
    private let disposeBag = DisposeBag()
    private let categoryItemRelay =  BehaviorRelay<[CategoryItem]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: DateUtility.stringFromDate(date: Date(), format: "yyyy年MM月"))

    init(categoryData: CategoryData,
         calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         displayDate: Date) {
        self.categoryData = categoryData
        self.calendarDate = calendarDate
        self.kakeiboModel = kakeiboModel
        self.displayDate = displayDate
    }

    private func acceptTableViewData() {
        guard let year = Int(DateUtility.stringFromDate(date: displayDate, format: "yyyy")),
              let month = Int(DateUtility.stringFromDate(date: displayDate, format: "MM")) else {
            return
        }
        var categoryItemArray: [CategoryItem] = []

        let kakeiboDataArray = kakeiboModel.loadMonthData(date: displayDate)
        let monthDateArray = calendarDate.loadCalendarDate(year: year, month: month, isContainOtherMonth: false)
        monthDateArray.forEach { date in
            let filterData = kakeiboDataArray.filter { kakeiboData in
                kakeiboData.categoryId.fetchId == categoryData.id && kakeiboData.date == date
            }
            guard !filterData.isEmpty else { return }
            let totalBalance = filterData.reduce(0) { $0 + $1.balance.fetchValue }
            categoryItemArray.append(
                CategoryItem(date: date, totalBalance: totalBalance, dataArray: filterData)
            )
        }
        categoryItemRelay.accept(categoryItemArray)
    }

    var categoryItemObservable: Observable<[CategoryItem]> {
        categoryItemRelay.asObservable()
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver()
    }

    func onViewDidLoad() {
        navigationTitleRelay.accept(categoryData.name)
        acceptTableViewData()
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
