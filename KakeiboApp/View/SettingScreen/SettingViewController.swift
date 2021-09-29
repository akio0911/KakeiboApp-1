//
//  SettingViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit
import RxSwift

class SettingViewController: UIViewController {

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
            .drive(onNext: { event in
                switch event {
                case .presentPasscodeVC:
                    break
                    // TODO: 画面遷移を実装
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
