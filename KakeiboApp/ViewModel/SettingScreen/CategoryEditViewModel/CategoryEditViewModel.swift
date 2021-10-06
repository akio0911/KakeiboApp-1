//
//  CategoryEditViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import RxSwift
import RxCocoa

protocol CategoryEditViewModelInput {
    func didTapAddBarButton()
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
        case presentIncomeCategoryAdd
        case presentExpenseCategoryAdd
        case presentIncomeCategoryEdit(CategoryData)
        case presentExpenseCategoryEdit(CategoryData)
    }

    private let categoryDataRepository: CategoryDataRepositoryProtocol
    private let categoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let eventRelay = PublishRelay<Event>()
    private var incomeCategoryDataArray: [CategoryData]
    private var expenseCategoryDataArray: [CategoryData]
    private var currentSegmentIndex = 0

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

    func didTapAddBarButton() {
        switch currentSegmentIndex {
        case 0:
            eventRelay.accept(.presentExpenseCategoryAdd)
        case 1:
            eventRelay.accept(.presentIncomeCategoryAdd)
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didSelectRowAt(index: IndexPath) {
        switch currentSegmentIndex {
        case 0:
            eventRelay.accept(.presentExpenseCategoryEdit(expenseCategoryDataArray[index.row]))
        case 1:
            eventRelay.accept(.presentIncomeCategoryEdit(incomeCategoryDataArray[index.row]))
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didDeleateCell(index: IndexPath) {
    }

    func didChangeSegmentIndex(index: Int) {
        switch index {
        case 0:
            categoryDataRelay.accept(expenseCategoryDataArray)
            currentSegmentIndex = 0
        case 1:
            categoryDataRelay.accept(incomeCategoryDataArray)
            currentSegmentIndex = 1
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
