//
//  SettingViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController {

    @IBOutlet private weak var settingStackView: UIStackView!
    @IBOutlet private weak var appStackView: UIStackView!
    @IBOutlet private weak var passcodeSwitch: UISwitch!
    @IBOutlet private weak var categoryEditButton: BackgroundHighlightedButton!
    @IBOutlet private weak var howToUseButton: BackgroundHighlightedButton!
    @IBOutlet private weak var shareButton: BackgroundHighlightedButton!
    @IBOutlet private weak var reviewButton: BackgroundHighlightedButton!

    private let viewModel: SettingViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: SettingViewModelType = SettingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        navigationItem.title = "設定"
        configureStackViewLayer()
    }

    private func setupBinding() {
        passcodeSwitch.rx.value
            .skip(1) // stateの値が流れるためスキップ
            .subscribe(onNext: viewModel.inputs.didValueChangedPasscodeSwitch)
            .disposed(by: disposeBag)

        categoryEditButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapCategoryEditButton)
            .disposed(by: disposeBag)

        howToUseButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapHowtoUseButton)
            .disposed(by: disposeBag)

        viewModel.outputs.isOnPasscode
            .drive(passcodeSwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentPasscodeVC:
                    let passcodeViewController = PasscodeViewController(
                        viewModel: PasscodeViewModel(mode: .create(.first))
                    )
                    let navigationController = UINavigationController(rootViewController: passcodeViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                case .pushCategoryEditVC:
                    let categoryEditViewController = CategoryEditViewController()
                    categoryEditViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(categoryEditViewController, animated: true)
                case .pushHowToVC:
                    let howToViewController = HowToViewController()
                    howToViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(howToViewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    private func configureStackViewLayer() {
        settingStackView.layer.cornerRadius = 10
        settingStackView.layer.masksToBounds = true
        appStackView.layer.cornerRadius = 10
        appStackView.layer.masksToBounds = true
    }
}
