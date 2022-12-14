//
//  CategoryEditViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import RxSwift
import RxCocoa

protocol CategoryEditViewModelInput {
    func onViewDidLoad()
    func didTapAddBarButton()
    func didSelectRowAt(indexPath: IndexPath)
    func didDeleateCell(indexPath: IndexPath)
    func didChangeSegmentIndex(selectedSegmentIndex: Int)
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
        case showErrorAlert
    }

    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let categoryDataRelay = BehaviorRelay<[CategoryData]>(value: [])
    private let eventRelay = PublishRelay<Event>()
    private var selectedSegmentIndex = 0
    private let disposeBag = DisposeBag()

    init(categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.categoryModel = categoryModel
        self.authType = authType
    }

    var categoryData: Observable<[CategoryData]> {
        categoryDataRelay.asObservable()
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewDidLoad() {
        categoryDataRelay.accept(categoryModel.expenseCategoryDataArray)
        EventBus.setCategoryData.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                switch self.selectedSegmentIndex {
                case 0:
                    // 支出が選択されている場合
                    self.categoryDataRelay.accept(self.categoryModel.expenseCategoryDataArray)
                case 1:
                    // 収入が選択されている場合
                    self.categoryDataRelay.accept(self.categoryModel.incomeCategoryDataArray)
                default:
                    fatalError()
                }
            })
            .disposed(by: disposeBag)
    }

    func didTapAddBarButton() {
        switch selectedSegmentIndex {
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

    func didSelectRowAt(indexPath: IndexPath) {
        switch selectedSegmentIndex {
        case 0:
            // 支出が選択されている場合
            eventRelay.accept(.presentExpenseCategoryEdit(categoryDataRelay.value[indexPath.row]))
        case 1:
            // 収入が選択されている場合
            eventRelay.accept(.presentIncomeCategoryEdit(categoryDataRelay.value[indexPath.row]))
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didDeleateCell(indexPath: IndexPath) {
        guard let userInfo = authType.userInfo else { return }
        switch selectedSegmentIndex {
        case 0:
            // 支出が選択されている場合
            categoryModel.deleteExpenseCategoryData(userId: userInfo.id, indexPath: indexPath) { [weak self] error in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.eventRelay.accept(.showErrorAlert)
                } else {
                    strongSelf.categoryDataRelay.accept(strongSelf.categoryModel.expenseCategoryDataArray)
                }
            }
        case 1:
            // 収入が選択されている場合
            categoryModel.deleteIncomeCategoryData(userId: userInfo.id, indexPath: indexPath) { [weak self] error in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.eventRelay.accept(.showErrorAlert)
                } else {
                    strongSelf.categoryDataRelay.accept(strongSelf.categoryModel.incomeCategoryDataArray)
                }
            }
        default:
            fatalError("想定していないSegmentIndexです。")
        }
    }

    func didChangeSegmentIndex(selectedSegmentIndex: Int) {
        switch selectedSegmentIndex {
        case 0:
            // 支出が選択されている場合
            categoryDataRelay.accept(categoryModel.expenseCategoryDataArray)
            self.selectedSegmentIndex = selectedSegmentIndex
        case 1:
            // 収入が選択されている場合
            categoryDataRelay.accept(categoryModel.incomeCategoryDataArray)
            self.selectedSegmentIndex = selectedSegmentIndex
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
