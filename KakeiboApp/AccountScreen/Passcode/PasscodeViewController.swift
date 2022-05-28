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
    @IBOutlet private weak var validateMessageLabel: UILabel!

    private var passcodeInputButtonView: PasscodeInputButtonView!
    private var keyImageStackView: KeyImageStackView!
    private let viewModel: PasscodeViewModelType
    private let disposeBag = DisposeBag()
    private let passcodePoster = PasscodePoster()

    private var validateMessage: (String) -> Void = { _ in }

    init(viewModel: PasscodeViewModelType,
         validateMessage: ((String) -> Void)? = nil) {
        self.viewModel = viewModel
        if let validateMessage = validateMessage {
            self.validateMessage = validateMessage
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyImageStackView()
        setupPasscodeInputButtonView()
        setupBinding()
    }

    private func setupKeyImageStackView() {
        keyImageStackView = KeyImageStackView()
        keyImageStackView.axis = .horizontal
        keyImageStackView.alignment = .center
        keyImageStackView.distribution = .fillProportionally
        keyImageStackView.spacing = 23
        keyImageStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyImageStackView)
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

        viewModel.outputs.isSetupCancelBarButton
            .drive(onNext: { [weak self] isSetup in
                guard let self = self else { return }
                if isSetup {
                    self.setupCancelBarButton()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.messageLabelText
            .drive(messageLable.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.firstKeyAlpha
            .drive(onNext: keyImageStackView.configureFirstKeyAlpha)
            .disposed(by: disposeBag)

        viewModel.outputs.secondKeyAlpha
            .drive(onNext: keyImageStackView.configureSecondKeyAlpha)
            .disposed(by: disposeBag)

        viewModel.outputs.thirdKeyAlpha
            .drive(onNext: keyImageStackView.configureThirdKeyAlpha)
            .disposed(by: disposeBag)

        viewModel.outputs.fourthKeyAlpha
            .drive(onNext: keyImageStackView.configureFourthKeyAlpha)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .dismiss:
                    strongSelf.dismiss(animated: true, completion: nil)
                case .pushPasscodeVC(let passcode):
                    strongSelf.pushPasscodeVC(passcode: passcode)
                case .popViewController:
                    strongSelf.navigationController?.popViewController(animated: true)
                    strongSelf.validateMessage("パスコードが一致しません。もう一度入力してください。")
                case .keyImageStackViewAnimation:
                    strongSelf.keyImageStackViewAnimation()
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            })
            .disposed(by: disposeBag)
    }

    private func pushPasscodeVC(passcode: [String]) {
        let passcodeViewController = PasscodeViewController(
            viewModel: PasscodeViewModel(
                mode: .create(.second(passcode))
            ),
            validateMessage: { [weak self] validateMessage in
                guard let self = self else { return }
                self.validateMessageLabel.text = validateMessage
            }
        )
        self.navigationController?.pushViewController(passcodeViewController, animated: true)
    }

    private func keyImageStackViewAnimation() {
        UIView.animate(withDuration: 0, animations: { [weak self] in
            guard let self = self else { return }
            self.keyImageStackView.center.x -= 30
        })
        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 0.1,
            initialSpringVelocity: 0,
            animations: { [weak self] in
                guard let self = self else { return }
                self.keyImageStackView.center.x += 30
            }
        )
    }

    private func setupCancelBarButton() {
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
        setupKeyImageStackViewConstraint()
        setupPasscodeInputButtonViewConstraint()
    }

    private func setupKeyImageStackViewConstraint() {
        NSLayoutConstraint.activate([
            keyImageStackView.topAnchor.constraint(equalTo: messageLable.bottomAnchor, constant: 20),
            keyImageStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupPasscodeInputButtonViewConstraint() {
        NSLayoutConstraint.activate([
            passcodeInputButtonView.topAnchor.constraint(equalTo: validateMessageLabel.bottomAnchor, constant: 30),
            passcodeInputButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passcodeInputButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passcodeInputButtonView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            passcodeInputButtonView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -70)
        ])
    }

    // MARK: - @objc(BarButtonItem)
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelButton()
        passcodePoster.didTapCancelButtonPost()
    }

    // MARK: - PasscodeInputButtonViewDelegate
    func didTapNumberButton(tapNumber: String) {
        viewModel.inputs.didTapNumberButton(tapNumber: tapNumber)
    }

    func didTapDeleteButton() {
        viewModel.inputs.didTapDeleteButton()
    }
}
