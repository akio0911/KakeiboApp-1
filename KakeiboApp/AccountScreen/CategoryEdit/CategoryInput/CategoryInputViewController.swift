//
//  CategoryInputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/06.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryInputViewController: UIViewController {
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private var contentsView: [UIView]!
    @IBOutlet private weak var mosaicView: UIView!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var hueSlider: UISlider!
    @IBOutlet private weak var saturationSlider: UISlider!
    @IBOutlet private weak var brightnessSlider: UISlider!
    @IBOutlet private weak var hueSliderBackView: GradientLayerView!
    @IBOutlet private weak var saturationSliedrBackView: GradientLayerView!
    @IBOutlet private weak var brightnessSliderBackView: GradientLayerView!
    @IBOutlet private weak var randomButton: BackgroundHighlightedButton!

    private let viewModel: CategoryInputViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: CategoryInputViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadius()
        setupBarButtonItem()
        setupTapGesture()
        setupBinding()
        viewModel.inputs.onViewDidLoad()
    }

    private func setupCornerRadius() {
        contentsView.forEach { cornerRadius(view: $0, cornerRadius: 10) }
        cornerRadius(view: mosaicView, cornerRadius: 10)
        cornerRadius(view: colorView, cornerRadius: 10)
        cornerRadius(view: hueSliderBackView, cornerRadius: 2)
        cornerRadius(view: saturationSliedrBackView, cornerRadius: 2)
        cornerRadius(view: brightnessSliderBackView, cornerRadius: 2)
        cornerRadius(view: randomButton, cornerRadius: 5)
    }

    private func cornerRadius(view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }

    private func setupBarButtonItem() {
        let saveBarButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(didTapSaveBarButton)
        )
        navigationItem.rightBarButtonItem = saveBarButton

        let cancelBarButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelBarButton)
        )
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    // swiftlint:disable:next function_body_length
    private func setupBinding() {
        hueSlider.rx.value
            .subscribe(onNext: viewModel.inputs.hueSliderValueChanged)
            .disposed(by: disposeBag)

        saturationSlider.rx.value
            .subscribe(onNext: viewModel.inputs.saturationSliderValueChanged)
            .disposed(by: disposeBag)

        brightnessSlider.rx.value
            .subscribe(onNext: viewModel.inputs.brightnessSliderValueChanged)
            .disposed(by: disposeBag)

        randomButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapRandomButton)
            .disposed(by: disposeBag)

        viewModel.outputs.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.categoryName
            .drive(categoryTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.categoryColor
            .drive(colorView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.outputs.hueSliderValue
            .drive(hueSlider.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.saturationSliderValue
            .drive(saturationSlider.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.brightnessSliderValue
            .drive(brightnessSlider.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.hueColors
            .drive(onNext: hueSliderBackView.setGradientLayer)
            .disposed(by: disposeBag)

        viewModel.outputs.saturationColors
            .drive(onNext: saturationSliedrBackView.setGradientLayer)
            .disposed(by: disposeBag)

        viewModel.outputs.brightnessColors
            .drive(onNext: brightnessSliderBackView.setGradientLayer)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                switch event {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                case .presentDismissAlert(let alertTitle, let message):
                    self?.showAlert(title: alertTitle, messege: message) { [weak self] in
                        self?.dismiss(animated: true)
                    }
                case .presentBecomeFirstResponderAlert(let alertTitle, let message):
                    self?.showAlert(title: alertTitle, messege: message) { [weak self] in
                        self?.categoryTextField.becomeFirstResponder()
                    }
                case .showErrorAlert:
                    self?.showErrorAlert()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - @objc
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelBarButton()
    }

    @objc private func didTapSaveBarButton() {
        viewModel.inputs.didTapSaveBarButton(name: categoryTextField.text!)
    }

    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
