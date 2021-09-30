//
//  PasscodeViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa

final class PasscodeViewController: UIViewController, PasscodeInputButtonViewDelegate {

    @IBOutlet private weak var messageLable: UILabel!
    @IBOutlet private weak var firstKeyImageView: UIImageView!
    @IBOutlet private weak var secondKeyImageView: UIImageView!
    @IBOutlet private weak var thirdKeyImageView: UIImageView!
    @IBOutlet private weak var fourthKeyImageView: UIImageView!

    private var passcodeInputButtonView: PasscodeInputButtonView!
    private let viewModel: PasscodeViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: PasscodeViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasscodeInputButtonView()
        setupBinding()
        setupBarButtonItem()
    }

    private func setupPasscodeInputButtonView() {
        passcodeInputButtonView = PasscodeInputButtonView()
        passcodeInputButtonView.delegate = self
        passcodeInputButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeInputButtonView)
    }

    private func setupBinding() {
        viewModel.outputs.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.outputs.messageLabelText
            .drive(messageLable.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.firstKeyAlpha
            .drive(firstKeyImageView.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.outputs.secondKeyAlpha
            .drive(secondKeyImageView.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.outputs.thirdKeyAlpha
            .drive(thirdKeyImageView.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.outputs.fourthKeyAlpha
            .drive(fourthKeyImageView.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .dismiss:
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupBarButtonItem() {
        let cancelBarButton =
            UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(didTapCancelBarButton)
            )
        navigationItem.rightBarButtonItem = cancelBarButton
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupPasscodeInputButtonViewConstraint()
    }

    private func setupPasscodeInputButtonViewConstraint() {
        NSLayoutConstraint.activate([
            passcodeInputButtonView.topAnchor.constraint(equalTo: messageLable.bottomAnchor, constant: 100),
            passcodeInputButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passcodeInputButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passcodeInputButtonView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            passcodeInputButtonView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -70)
        ])
    }

    // MARK: - @objc(BarButtonItem)
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelButton()
    }

    // MARK: - PasscodeInputButtonViewDelegate
    func didTapNumberButton(tapNumber: String) {
        viewModel.inputs.didTapNumberButton(tapNumber: tapNumber)
    }

    func didTapDeleteButton() {
        viewModel.inputs.didTapDeleteButton()
    }
}
