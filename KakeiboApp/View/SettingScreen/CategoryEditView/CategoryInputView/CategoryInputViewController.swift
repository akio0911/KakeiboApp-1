//
//  CategoryInputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/06.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryInputViewController: UIViewController {

    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private var contentsView: [UIView]!
    @IBOutlet private weak var mosaicView: UIView!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var hueSlider: UISlider!
    @IBOutlet private weak var saturationSlider: UISlider!
    @IBOutlet private weak var brightnessSlider: UISlider!

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
        contentsView.forEach { setupCornerRadius(view: $0) }
        setupCornerRadius(view: mosaicView)
        setupCornerRadius(view: colorView)
        setupBarButtonItem()
        setupTapGesture()
        setupBinding()
    }

    private func setupCornerRadius(view: UIView) {
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
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

    private func setupBinding() {
        hueSlider.rx.value
            .skip(1) // 初期値をスキップ
            .subscribe(onNext: viewModel.inputs.hueSliderValueChanged)
            .disposed(by: disposeBag)

        saturationSlider.rx.value
            .skip(1) // 初期値をスキップ
            .subscribe(onNext: viewModel.inputs.saturationSliderValueChanged)
            .disposed(by: disposeBag)

        brightnessSlider.rx.value
            .skip(1) // 初期値をスキップ
            .subscribe(onNext: viewModel.inputs.brightnessSliderValueChanged)
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

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - @objc
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelBarButton()
    }

    @objc private func didTapSaveBarButton() {
        viewModel.inputs.didTapSaveBarButton()
    }

    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
