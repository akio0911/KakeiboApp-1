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

    private func setupMode() {
        switch viewModel.outputs.mode {
        case .login:
            let login = "ログイン"
            userNameStackView.isHidden = true
            enterButton.setTitle(login, for: .normal)
            setupBarButtonItem(enterButtonTitle: login)
        case .create:
            let register = "登録"
            forgotPasswordButton.removeFromSuperview()
            enterButton.setTitle(register, for: .normal)
            setupBarButtonItem(enterButtonTitle: register)
        case .forgotPassword:
            userNameStackView.isHidden = true
            passwordStackView.isHidden = true
            forgotPasswordButton.removeFromSuperview()
            enterButton.setTitle("再設定メールを送信", for: .normal)
            setupBarButtonItem(enterButtonTitle: "送信")
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
                        UIImage(systemName: "eye"),for: .normal)
                } else {
                    // 入力内容が表示
                    strongSelf.passwordSecureTextButton.setImage(
                        UIImage(systemName: "eye.slash"),for: .normal)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .dismiss:
                    strongSelf.dismiss(animated: true, completion: nil)
                case .presentErrorAlertView(let alertTitle, let message):
                    strongSelf.presentAlert(alertTitle: alertTitle, message: message,
                                            action: strongSelf.errorAction())
                case .presentDismissAlertView(let alertTitle, let message):
                    strongSelf.presentAlert(alertTitle: alertTitle, message: message,
                                            action: strongSelf.dismissAction())
                case .presentPopVCAlertView(let alertTitle, let message):
                    strongSelf.presentAlert(alertTitle: alertTitle, message: message,
                                            action: strongSelf.popVCAction())
                case .pushAuthFormForgotPasswordMode:
                    let authFormViewController = AuthFormViewController(
                        viewModel: AuthFormViewModel(mode: .forgotPassword)
                    )
                    strongSelf.navigationController?
                        .pushViewController(authFormViewController, animated: true)
                case .popVC:
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    private func didTapEnterButton() {
        viewModel.inputs.didTapEnterButton(
            userName: userNameTextField.text!,
            mail: mailTextField.text!,
            password: passwordTextField.text!
        )
    }

    private func presentAlert(alertTitle: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func errorAction() -> UIAlertAction {
        UIAlertAction(title: "OK", style: .default, handler: nil)
    }

    private func dismissAction() -> UIAlertAction {
        UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }

    private func popVCAction() -> UIAlertAction {
        UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.popViewController(animated: true)
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
}
