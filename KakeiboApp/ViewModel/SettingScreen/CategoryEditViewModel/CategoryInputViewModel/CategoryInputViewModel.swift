//
//  CategoryInputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/06.
//

import RxSwift
import RxCocoa

protocol CategoryInputViewModelInput {
    func didTapSaveBarButton()
    func didTapCancelBarButton()
    func hueSliderValueChanged(value: Int)
    func saturationSliderValueChanged(value: Int)
    func brightnessSliderValueChanged(value: Int)
}

protocol CategoryInputViewModelOutput {
    var event: Driver<CategoryInputViewModel.Event> { get }
    var navigationTitle: Driver<String> { get }
    var categoryName: Driver<String> { get }
    var categoryColor: Driver<UIColor> { get }
    var hueSliderValue: Driver<Float> { get }
    var saturationSliderValue: Driver<Float> { get }
    var brightnessSliderValue: Driver<Float> { get }
}

protocol CategoryInputViewModelType {
    var inputs: CategoryInputViewModelInput { get }
    var outputs: CategoryInputViewModelOutput { get }
}

final class CategoryInputViewModel: CategoryInputViewModelInput, CategoryInputViewModelOutput {
    enum Event {
        case dissmiss
    }

    enum Mode {
        case incomeCategoryAdd
        case expenseCategoryAdd
        case incomeCategoryEdit(CategoryData)
        case expenseCategoryEdit(CategoryData)
    }

    private let mode: Mode
    private let eventRelay = PublishRelay<Event>()
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let categoryNameRelay = BehaviorRelay<String>(value: "")
    private let categoryColorRelay = BehaviorRelay<UIColor>(
        value: UIColor(hue: 0.5, saturation: 0.5, brightness: 0.5, alpha: 0.5))
    private let hueSliderValueRelay = BehaviorRelay<Float>(value: 0.5)
    private let saturationSliderValueRelay = BehaviorRelay<Float>(value: 0.5)
    private let brightnessSliderValueRelay = BehaviorRelay<Float>(value: 0.5)

    init(mode: Mode) {
        self.mode = mode
        setupMode(mode: mode)
    }

    private func setupMode(mode: Mode) {
        let incomeNavigationTitle = "収支カテゴリー"
        let expenseNavigationTitle = "支出カテゴリー"
        switch mode {
        case .incomeCategoryAdd:
            navigationTitleRelay.accept(incomeNavigationTitle)
        case .expenseCategoryAdd:
            navigationTitleRelay.accept(expenseNavigationTitle)
        case .incomeCategoryEdit(let categoryData):
            navigationTitleRelay.accept(incomeNavigationTitle)
            setCategoryData(data: categoryData)
        case .expenseCategoryEdit(let categoryData):
            navigationTitleRelay.accept(expenseNavigationTitle)
            setCategoryData(data: categoryData)
        }
    }

    private func setCategoryData(data: CategoryData) {
        categoryNameRelay.accept(data.name)
        categoryColorRelay.accept(data.color)
        let hsba = data.color.hsba
        hueSliderValueRelay.accept(Float(hsba.hue * 100))
        saturationSliderValueRelay.accept(Float(hsba.saturation * 100))
        brightnessSliderValueRelay.accept(Float(hsba.brightness * 100))
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var categoryName: Driver<String> {
        categoryNameRelay.asDriver(onErrorDriveWith: .empty())
    }

    var categoryColor: Driver<UIColor> {
        categoryColorRelay.asDriver(onErrorDriveWith: .empty())
    }

    var hueSliderValue: Driver<Float> {
        hueSliderValueRelay.asDriver(onErrorDriveWith: .empty())
    }

    var saturationSliderValue: Driver<Float> {
        saturationSliderValueRelay.asDriver(onErrorDriveWith: .empty())
    }

    var brightnessSliderValue: Driver<Float> {
        brightnessSliderValueRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapSaveBarButton() {
    }

    func didTapCancelBarButton() {
        eventRelay.accept(.dissmiss)
    }

    func hueSliderValueChanged(value: Int) {
    }

    func saturationSliderValueChanged(value: Int) {
    }

    func brightnessSliderValueChanged(value: Int) {
    }
}

extension CategoryInputViewModel: CategoryInputViewModelType {
    var inputs: CategoryInputViewModelInput {
        return self
    }

    var outputs: CategoryInputViewModelOutput {
        return self
    }
}
