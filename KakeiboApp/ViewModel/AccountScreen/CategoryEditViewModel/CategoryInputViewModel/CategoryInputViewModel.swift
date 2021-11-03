//
//  CategoryInputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/06.
//

import RxSwift
import RxCocoa

protocol CategoryInputViewModelInput {
    func didTapSaveBarButton(name: String)
    func didTapCancelBarButton()
    func hueSliderValueChanged(value: Float)
    func saturationSliderValueChanged(value: Float)
    func brightnessSliderValueChanged(value: Float)
    func didTapRandomButton()
}

protocol CategoryInputViewModelOutput {
    var event: Driver<CategoryInputViewModel.Event> { get }
    var navigationTitle: Driver<String> { get }
    var categoryName: Driver<String> { get }
    var categoryColor: Driver<UIColor> { get }
    var hueSliderValue: Driver<Float> { get }
    var saturationSliderValue: Driver<Float> { get }
    var brightnessSliderValue: Driver<Float> { get }
    var hueColors: Driver<[CGColor]> { get }
    var saturationColors: Driver<[CGColor]> { get }
    var brightnessColors: Driver<[CGColor]> { get }
}

protocol CategoryInputViewModelType {
    var inputs: CategoryInputViewModelInput { get }
    var outputs: CategoryInputViewModelOutput { get }
}

final class CategoryInputViewModel: CategoryInputViewModelInput, CategoryInputViewModelOutput {
    enum Event {
        case dismiss
    }

    enum Mode {
        case incomeCategoryAdd
        case expenseCategoryAdd
        case incomeCategoryEdit(CategoryData)
        case expenseCategoryEdit(CategoryData)
    }

    private let mode: Mode
    private let categoryModel: CategoryModelProtocol
    private let authType: AuthTypeProtocol
    private let eventRelay = PublishRelay<Event>()
    private let disposeBag = DisposeBag()
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let categoryNameRelay = BehaviorRelay<String>(value: "")
    private let categoryColorRelay = BehaviorRelay<UIColor>(value: UIColor())
    private let hueSliderValueRelay = BehaviorRelay<Float>(value: 1)
    private let saturationSliderValueRelay = BehaviorRelay<Float>(value: 1)
    private let brightnessSliderValueRelay = BehaviorRelay<Float>(value: 1)

    // hueSliderのbackViewのグラデーション用
    private let hueColorsRelay = BehaviorRelay<[CGColor]>(value: [])
    // saturationSliderのbackViewのグラデーション用
    private let saturationColorsRelay = BehaviorRelay<[CGColor]>(value: [])
    // brightnessSliderのbackViewのグラデーション用
    private let brightnessColorsRelay = BehaviorRelay<[CGColor]>(value: [])

    private var currentHue: CGFloat = 1
    private var currentSaturation: CGFloat = 1
    private var currentBrightness: CGFloat = 1

    private var incomeCategoryDataArray: [CategoryData] = []
    private var expenseCategoryDataArray: [CategoryData] = []
    private var userInfo: UserInfo?

    init(mode: Mode,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel,
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.mode = mode
        self.categoryModel = categoryModel
        self.authType = authType
        setupBinding()
        setupMode(mode: mode)
        hueColorsRelay.accept(createColors(saturation: 1, brightness: 1))
    }

    private func setupBinding() {
        categoryModel.incomeCategoryData
            .subscribe(onNext: { [weak self] incomeCategoryData in
                guard let strongSelf = self else { return }
                strongSelf.incomeCategoryDataArray = incomeCategoryData
            })
            .disposed(by: disposeBag)

        categoryModel.expenseCategoryData
            .subscribe(onNext: { [weak self] expenseCategoryData in
                guard let strongSelf = self else { return }
                strongSelf.expenseCategoryDataArray = expenseCategoryData
            })
            .disposed(by: disposeBag)

        authType.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                guard let strongSelf = self else { return }
                strongSelf.userInfo = userInfo
            })
            .disposed(by: disposeBag)
    }

    private func setupMode(mode: Mode) {
        let incomeNavigationTitle = "収支カテゴリー"
        let expenseNavigationTitle = "支出カテゴリー"
        switch mode {
        case .incomeCategoryAdd:
            navigationTitleRelay.accept(incomeNavigationTitle)
            setRandomColor()
        case .expenseCategoryAdd:
            navigationTitleRelay.accept(expenseNavigationTitle)
            setRandomColor()
        case .incomeCategoryEdit(let categoryData):
            navigationTitleRelay.accept(incomeNavigationTitle)
            setCategoryData(data: categoryData)
        case .expenseCategoryEdit(let categoryData):
            navigationTitleRelay.accept(expenseNavigationTitle)
            setCategoryData(data: categoryData)
        }
    }

    private func setRandomColor() {
        let hue = CGFloat.random(in: 0.01...1)
        let saturation = CGFloat.random(in: 0.16...1)
        let brightness = CGFloat.random(in: 0.62...1)
        categoryColorRelay.accept(UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1))
        hueSliderValueRelay.accept(Float(hue))
        saturationSliderValueRelay.accept(Float(saturation))
        brightnessSliderValueRelay.accept(Float(brightness))
        saturationColorsRelay.accept(createColors(hue: hue, brightness: brightness))
        brightnessColorsRelay.accept(createColors(hue: hue, saturation: saturation))
        currentHue = hue
        currentSaturation = saturation
        currentBrightness = brightness
    }

    private func setCategoryData(data: CategoryData) {
        categoryNameRelay.accept(data.name)
        categoryColorRelay.accept(data.color)
        let hsba = data.color.hsba
        hueSliderValueRelay.accept(Float(hsba.hue))
        saturationSliderValueRelay.accept(Float(hsba.saturation))
        brightnessSliderValueRelay.accept(Float(hsba.brightness))
        saturationColorsRelay.accept(createColors(hue: hsba.hue, brightness: hsba.brightness))
        brightnessColorsRelay.accept(createColors(hue: hsba.hue, saturation: hsba.saturation))
        currentHue = hsba.hue
        currentSaturation = hsba.saturation
        currentBrightness = hsba.brightness
    }

    private func createColors(hue: CGFloat? = nil,
                              saturation: CGFloat? = nil,
                              brightness: CGFloat? = nil) -> [CGColor] {
        let increment: CGFloat = 0.02
        let hueArray = [CGFloat](stride(from: 0.0, to: 1.0, by: increment))
        let saturationArray = [CGFloat](stride(from: 0.16, to: 1.0, by: increment))
        let brightnessArray = [CGFloat](stride(from: 0.62, to: 1.0, by: increment))
        var colors: [CGColor] = []
        switch (hue, saturation, brightness) {
        case let (nil, .some(saturation), .some(brightness)):
            colors = hueArray.map { hue in
                UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1).cgColor
            }
        case let (.some(hue), nil, .some(brightness)):
            colors = saturationArray.map { saturation in
                UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1).cgColor
            }
        case let (.some(hue), .some(saturation), nil):
            colors = brightnessArray.map { brightness in
                UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1).cgColor
            }
        default:
            break
        }
        return colors
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

    var hueColors: Driver<[CGColor]> {
        hueColorsRelay.asDriver(onErrorDriveWith: .empty())
    }

    var saturationColors: Driver<[CGColor]> {
        saturationColorsRelay.asDriver(onErrorDriveWith: .empty())
    }

    var brightnessColors: Driver<[CGColor]> {
        brightnessColorsRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapSaveBarButton(name: String) {
        switch mode {
        case .incomeCategoryAdd:
            let categoryData =
            CategoryData(
                id: UUID().uuidString,
                displayOrder: incomeCategoryDataArray.count,
                name: name,
                color: categoryColorRelay.value
            )
            incomeCategoryDataArray.append(categoryData)
            categoryModel.setIncomeCategoryData(userId: userInfo?.id, data: categoryData)
        case .expenseCategoryAdd:
            let categoryData =
                CategoryData(
                    id: UUID().uuidString,
                    displayOrder: expenseCategoryDataArray.count,
                    name: name,
                    color: categoryColorRelay.value
                )
            expenseCategoryDataArray.append(categoryData)
            categoryModel.setExpenseCategoryData(userId: userInfo?.id, data: categoryData)
        case .incomeCategoryEdit(let categoryData):
            let categoryData =
            CategoryData(
                id: categoryData.id,
                displayOrder: categoryData.displayOrder,
                name: name,
                color: categoryColorRelay.value
            )
            categoryModel.setIncomeCategoryData(userId: userInfo?.id, data: categoryData)
        case .expenseCategoryEdit(let categoryData):
            let categoryData =
            CategoryData(
                id: categoryData.id,
                displayOrder: categoryData.displayOrder,
                name: name,
                color: categoryColorRelay.value
            )
            categoryModel.setExpenseCategoryData(userId: userInfo?.id, data: categoryData)
        }
        eventRelay.accept(.dismiss)
    }

    func didTapCancelBarButton() {
        eventRelay.accept(.dismiss)
    }

    func hueSliderValueChanged(value: Float) {
        let hue = CGFloat(value)
        let categoryColorHSBA = categoryColorRelay.value.hsba
        let categoryColor =
        UIColor(hue: hue, saturation: categoryColorHSBA.saturation, brightness: categoryColorHSBA.brightness, alpha: 1)
        categoryColorRelay.accept(categoryColor)
        saturationColorsRelay.accept(createColors(hue: hue, brightness: currentBrightness))
        brightnessColorsRelay.accept(createColors(hue: hue, saturation: currentSaturation))
        currentHue = hue
    }

    func saturationSliderValueChanged(value: Float) {
        let saturation = CGFloat(value)
        let categoryColorHSBA = categoryColorRelay.value.hsba
        let categoryColor =
        UIColor(hue: categoryColorHSBA.hue, saturation: saturation, brightness: categoryColorHSBA.brightness, alpha: 1)
        categoryColorRelay.accept(categoryColor)
        brightnessColorsRelay.accept(createColors(hue: currentHue, saturation: saturation))
        currentSaturation = saturation
    }

    func brightnessSliderValueChanged(value: Float) {
        let brightness = CGFloat(value)
        let categoryColorHSBA = categoryColorRelay.value.hsba
        let categoryColor =
        UIColor(hue: categoryColorHSBA.hue, saturation: categoryColorHSBA.saturation, brightness: brightness, alpha: 1)
        categoryColorRelay.accept(categoryColor)
        saturationColorsRelay.accept(createColors(hue: currentHue, brightness: brightness))
        currentBrightness = brightness
    }

    func didTapRandomButton() {
         setRandomColor()
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
