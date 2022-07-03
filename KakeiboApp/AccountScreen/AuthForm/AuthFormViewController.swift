//
//  AuthFormViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import UIKit
import RxSwift
import RxCocoa

class AuthFormViewController: UIViewController {
    @IBOutlet private weak var authFormImageView: UIImageView!
    @IBOutlet private weak var userNameStackView: UIStackView!
    @IBOutlet private weak var mailStackView: UIStackView!
    @IBOutlet private weak var passwordStackView: UIStackView!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var mailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private var iconViews: [UIView]!
    @IBOutlet private weak var enterButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var passwordSecureTextButton: UIButton!

    private let viewModel: AuthFormViewModelType
    private let disposeBag = DisposeBag()
    private let eyeImage = UIImage(systemName: "eye")
    private let eyeSlashImage = UIImage(systemName: "eye.slash")

    init(viewModel: AuthFormViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadius()
        setupTapGesture()
        setupMode()
        setupBinding()
    }

    private func setupCornerRadius() {
        // 各入力欄をフィレット
        let contentsStackView: [UIStackView] = [
            userNameStackView,
            mailStackView,
            passwordStackView
        ]
        contentsStackView.forEach {
            $0.layer.cornerRadius = $0.bounds.height / 2
            $0.layer.masksToBounds = true
        }

        // 各入力欄アイコンをフィレット
        iconViews.forEach {
            $0.layer.cornerRadius = $0.bounds.height / 2
            $0.layer.masksToBounds = true
        }

        // enterButtonをフィレット
        enterButton.layer.cornerRadius = enterButton.bounds.height / 2
        enterButton.layer.masksToBounds = true
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapView(_:))
        )
        view.addGestureRecognizer(tapGesture)
    }

    private func setupMode() {
        switch viewModel.outputs.mode {
        case .login:
            let login = R.string.localizable.login()
            userNameStackView.isHidden = true
            enterButton.setTitle(login, for: .normal)
            setupBarButtonItem(enterButtonTitle: login)
        case .forgotPassword:
            userNameStackView.isHidden = true
            passwordStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle(R.string.localizable.resetEmailSend(), for: .normal)
            setupBarButtonItem(enterButtonTitle: R.string.localizable.sending())
        case .register:
            let next = R.string.localizable.next()
            passwordStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle(next, for: .normal)
            setupBarButtonItem(enterButtonTitle: next)
        case .setPassword:
            userNameStackView.isHidden = true
            mailStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle(R.string.localizable.passwordSetting(), for: .normal)
            setupBarButtonItem(enterButtonTitle: R.string.localizable.setting())
        }
    }

    private func setupBarButtonItem(enterButtonTitle: String) {
        let enterBarButton = UIBarButtonItem(
            title: enterButtonTitle,
            style: .plain,
            target: self,
            action: #selector(didTapEnterBarButton)
        )
        navigationItem.rightBarButtonItem = enterBarButton

        let cancelBarButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelBarButton)
        )
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    private func setupBinding() {
        enterButton.rx.tap
            .subscribe(onNext: didTapEnterButton)
            .disposed(by: disposeBag)

        forgotPasswordButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapForgotPasswordButton)
            .disposed(by: disposeBag)

        passwordSecureTextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.passwordTextField.isSecureTextEntry.toggle()
                if strongSelf.passwordTextField.isSecureTextEntry {
                    // 入力内容が非表示
                    strongSelf.passwordSecureTextButton.setImage(
                        strongSelf.eyeImage, for: .normal)
                } else {
                    // 入力内容が表示
                    strongSelf.passwordSecureTextButton.setImage(
                        strongSelf.eyeSlashImage, for: .normal)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                strongSelf.executeEvent(event: event)
            })
            .disposed(by: disposeBag)
    }

    private func didTapEnterButton() {
        viewModel.inputs.didTapEnterButton(
            userName: userNameTextField.text!,
            email: mailTextField.text!,
            password: passwordTextField.text!
        )
    }

    private func executeEvent(event: AuthFormViewModel.Event) {
        switch event {
        case .presentErrorAlertView(let alertTitle, let message):
            showAlert(title: alertTitle, messege: message)
        case .presentPopVCAlertView(let alertTitle, let message):
            showAlert(title: alertTitle, messege: message) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        case .pushEmailLinkAuthSuccess(email: let email):
            let emailLinkAuthSuccessViewController = EmailLinkAuthSuccessViewController(
                viewModel: EmailLinkAuthSuccessViewModel(email: email)
            )
            navigationController?.pushViewController(emailLinkAuthSuccessViewController, animated: true)
        case .pushAuthFormForgotPasswordMode:
            let authFormViewController = AuthFormViewController(
                viewModel: AuthFormViewModel(mode: .forgotPassword)
            )
            navigationController?
                .pushViewController(authFormViewController, animated: true)
        case .popVC:
            navigationController?.popViewController(animated: true)
        case .popToRootVC:
            navigationController?.popToRootViewController(animated: true)
        case .startAnimating:
            showProgress()
        case .stopAnimating:
            hideProgress()
        }
    }

    // MARK: - viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUserFormImageViewCornerRadius()
    }

    private func setupUserFormImageViewCornerRadius() {
        // userFormImageViewをフィレット
        let cornerRadiusRate: CGFloat = 0.15
        authFormImageView.layer.cornerRadius = authFormImageView.bounds.height * cornerRadiusRate
        authFormImageView.layer.masksToBounds = true
    }

    // MARK: - @objc
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelButtton()
    }

    @objc private func didTapEnterBarButton() {
        didTapEnterButton()
    }

    @objc private func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
