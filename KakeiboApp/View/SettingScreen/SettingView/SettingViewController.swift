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
    @IBOutlet private weak var passcodeSwitch: UISwitch!

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
    }

    private func setupBinding() {
        passcodeSwitch.rx.value
            .subscribe(onNext: viewModel.inputs.didValueChangedPasscodeSwitch)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentPasscodeVC:
                    let passcodeViewController = PasscodeViewController()
                    let navigationController = UINavigationController(rootViewController: passcodeViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStackViewLayer()
    }

    private func configureStackViewLayer() {
        settingStackView.layer.cornerRadius = 10
        settingStackView.layer.masksToBounds = true
    }
}
