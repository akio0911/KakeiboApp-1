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

    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let categoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let eventRelay = PublishRelay<Event>()
    private var incomeCategoryDataArray: [CategoryData] = []
    private var expenseCategoryDataArray: [CategoryData] = []
    private var userInfo: UserInfo?
    private var currentSegmentIndex = 0

    init(categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.categoryModel = categoryModel
        self.authType = authType
        setupBinding()
    }

    private func setupBinding() {
        categoryModel.incomeCategoryData
            .subscribe(onNext: { [weak self] incomeCategoryDataArray in
                guard let self = self else { return }
                self.categoryDataRelay.accept(incomeCategoryDataArray)
                self.incomeCategoryDataArray = incomeCategoryDataArray
            })
            .disposed(by: disposeBag)

        categoryModel.expenseCategoryData
            .subscribe(onNext: { [weak self] expenseCategoryDataArray in
                guard let self = self else { return }
                self.categoryDataRelay.accept(expenseCategoryDataArray)
                self.expenseCategoryDataArray = expenseCategoryDataArray
            })
            .disposed(by: disposeBag)

        authType.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                guard let strongSelf = self else { return }
                strongSelf.userInfo = userInfo
            })
            .disposed(by: disposeBag)
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
            // 支出が選択されている場合
            eventRelay.accept(.presentExpenseCategoryAdd)
        case 1:
            // 収入が選択されている場合
            eventRelay.accept(.presentIncomeCategoryAdd)
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didSelectRowAt(index: IndexPath) {
        switch currentSegmentIndex {
        case 0:
            // 支出が選択されている場合
            eventRelay.accept(.presentExpenseCategoryEdit(expenseCategoryDataArray[index.row]))
        case 1:
            // 収入が選択されている場合
            eventRelay.accept(.presentIncomeCategoryEdit(incomeCategoryDataArray[index.row]))
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didDeleateCell(index: IndexPath) {
        guard let userInfo = userInfo else { return }
        switch currentSegmentIndex {
        case 0:
            // 支出が選択されている場合
            categoryModel.deleteExpenseCategoryData(
                userId: userInfo.id, data: expenseCategoryDataArray[index.row]
            )
            expenseCategoryDataArray.remove(at: index.row)
            expenseCategoryDataArray.indices.forEach {
                expenseCategoryDataArray[$0].displayOrder = $0
            }
            categoryModel.setExpenseCategoryDataArray(userId: userInfo.id, data: expenseCategoryDataArray)
        case 1:
            // 収入が選択されている場合
            categoryModel.deleteIncomeCategoryData(
                userId: userInfo.id, data: incomeCategoryDataArray[index.row]
            )
            incomeCategoryDataArray.remove(at: index.row)
            incomeCategoryDataArray.indices.forEach {
                incomeCategoryDataArray[$0].displayOrder = $0
            }
            categoryModel.setIncomeCategoryDataArray(userId: userInfo.id, data: incomeCategoryDataArray)
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didChangeSegmentIndex(index: Int) {
        switch index {
        case 0:
            // 支出が選択されている場合
            categoryDataRelay.accept(expenseCategoryDataArray)
            currentSegmentIndex = 0
        case 1:
            // 収入が選択されている場合
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
