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
    private let term: GraphViewModel.Term

    init(categoryData: CategoryData,
         calendarDate: CalendarDateProtocol = ModelLocator.shared.calendarDate,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         displayDate: Date,
         term: GraphViewModel.Term) {
        self.categoryData = categoryData
        self.calendarDate = calendarDate
        self.kakeiboModel = kakeiboModel
        self.displayDate = displayDate
        self.term = term
    }

    private func acceptTableViewData() {
        var categoryItemArray: [CategoryItem] = []
        let kakeiboDataArray: [KakeiboData]
        switch term {
        case .yearly:
            kakeiboDataArray = kakeiboModel.loadYearData(date: displayDate)
        case .monthly:
            kakeiboDataArray = kakeiboModel.loadMonthData(date: displayDate)
        }

        let sortedKakeiboDataArray = kakeiboDataArray.sorted { $0.date < $1.date }
    top: for kakeiboData in sortedKakeiboDataArray {
        guard kakeiboData.categoryId.fetchId == categoryData.id else { continue }
        for (index, value) in categoryItemArray.enumerated() {
            guard kakeiboData.date == value.date else { continue }
            categoryItemArray[index].dataArray.append(kakeiboData)
            categoryItemArray[index].totalBalance += kakeiboData.balance.fetchValue
            continue top
        }
        categoryItemArray.append(
            CategoryItem(
                date: kakeiboData.date,
                totalBalance: kakeiboData.balance.fetchValue,
                dataArray: [kakeiboData]
            )
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
