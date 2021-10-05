//
//  CategoryEditViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import RxSwift
import RxCocoa

protocol CategoryEditViewModelInput {
    func didTapInputBarButton()
    func didSelectRowAt(index: IndexPath)
    func didDeleateCell(index: IndexPath)
    func didChangeSegmentIndex(index: Int)
}

protocol CategoryEditViewModelOutput {
    var categoryData: Observable<[CategoryData]> { get }
    var event: Driver<CategoryEditViewModel.Event> { get }
}

protocol CategoryEditViewModelType {
    var inputs: CategoryEditViewModelInput { get }
    var outputs: CategoryEditViewModelOutput { get }
}

final class CategoryEditViewModel: CategoryEditViewModelInput, CategoryEditViewModelOutput {

    enum Event {
    }

    private let categoryDataRepository: CategoryDataRepositoryProtocol
    private let categoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let eventRelay = PublishRelay<Event>()
    private var incomeCategoryDataArray: [CategoryData]
    private var expenseCategoryDataArray: [CategoryData]

    init(categoryDataRepository: CategoryDataRepositoryProtocol = CategoryDataRepository()) {
        self.categoryDataRepository = categoryDataRepository
        incomeCategoryDataArray =
        categoryDataRepository.loadIncomeCategoryData()
        expenseCategoryDataArray =
        categoryDataRepository.loadExpenseCategoryData()
        categoryDataRelay.accept(expenseCategoryDataArray)
    }

    var categoryData: Observable<[CategoryData]> {
        categoryDataRelay.asObservable()
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapInputBarButton() {
    }

    func didSelectRowAt(index: IndexPath) {
    }

    func didDeleateCell(index: IndexPath) {
    }

    func didChangeSegmentIndex(index: Int) {
        switch index {
        case 1:
            categoryDataRelay.accept(expenseCategoryDataArray)
        case 2:
            categoryDataRelay.accept(incomeCategoryDataArray)
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }
}

extension CategoryEditViewModel: CategoryEditViewModelType {
    var inputs: CategoryEditViewModelInput {
        return self
    }

    var outputs: CategoryEditViewModelOutput {
        return self
    }
}
