//
//  AuthFormViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import UIKit
import RxSwift
import RxCocoa

class AuthFormViewController: UIViewController, UITextFieldDelegate {
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
    @IBOutlet private weak var baseScrollView: UIScrollView!
    @IBOutlet private weak var contentsView: UIView!

    private let viewModel: AuthFormViewModelType
    private let disposeBag = DisposeBag()
    private var activityIndicatorView: UIActivityIndicatorView!
    // 編集中のTextField
    private var editingTextField: UITextField?
    private let eyeImage = UIImage(systemName: "eye")
    private let eyeSlashImage = UIImage(systemName: "eye.slash")
    private let alertTextField = "alertTextField"

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
        setupAuthFormTextFields()
        setupKeyboardNotification()
        setupCornerRadius()
        setupTapGesture()
        setupMode()
        addActivityIndicatorView()
        setupBinding()
    }

    private func setupAuthFormTextFields() {
        let authFormTextFields = [
            userNameTextField,
            mailTextField,
            passwordTextField
        ]
        authFormTextFields.forEach {
            $0?.delegate = self
            $0?.inputAccessoryView = toolBar
        }
    }

    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapKeyboardDoneButton)
        )
        toolbar.setItems([spacer, doneButton], animated: true)
        return toolbar
    }()

    private func setupKeyboardNotification() {
        let notification = NotificationCenter.default
        // キーボードが表示された
        notification.addObserver(self,
                                 selector: #selector(keyboardDidShow(_:)),
                                 name: UIResponder.keyboardDidShowNotification,
                                 object: nil)
        // キーボードが退場した
        notification.addObserver(self,
                                 selector: #selector(keyboardDidHide(_:)),
                                 name: UIResponder.keyboardDidHideNotification,
                                 object: nil)
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
            let login = "ログイン"
            userNameStackView.isHidden = true
            enterButton.setTitle(login, for: .normal)
            setupBarButtonItem(enterButtonTitle: login)
        case .forgotPassword:
            userNameStackView.isHidden = true
            passwordStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle("再設定メールを送信", for: .normal)
            setupBarButtonItem(enterButtonTitle: "送信")
        case .register:
            let next = "次へ"
            passwordStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle(next, for: .normal)
            setupBarButtonItem(enterButtonTitle: next)
        case .setPassword:
            userNameStackView.isHidden = true
            mailStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            enterButton.setTitle("パスワードを設定", for: .normal)
            setupBarButtonItem(enterButtonTitle: "設定")
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

    // ActivityIndicatorViewを反映
    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.backgroundColor = .systemGray5.withAlphaComponent(0.6)
        activityIndicatorView.layer.cornerRadius = 10
        activityIndicatorView.layer.masksToBounds = true
        view.addSubview(activityIndicatorView)
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
            presentAlert(alertTitle: alertTitle, message: message,
                         action: errorAction())
        case .presentPopVCAlertView(let alertTitle, let message):
            presentAlert(alertTitle: alertTitle, message: message,
                         action: popVCAction())
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
            activityIndicatorView.startAnimating()
        case .stopAnimating:
            activityIndicatorView.stopAnimating()
        }
    }

    private func presentAlert(alertTitle: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func errorAction(title: String = "OK") -> UIAlertAction {
        UIAlertAction(title: title, style: .default, handler: nil)
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
        setupActivityIndicatorCenter()
    }

    private func setupUserFormImageViewCornerRadius() {
        // userFormImageViewをフィレット
        let cornerRadiusRate: CGFloat = 0.15
        authFormImageView.layer.cornerRadius = authFormImageView.bounds.height * cornerRadiusRate
        authFormImageView.layer.masksToBounds = true
    }

    private func setupActivityIndicatorCenter() {
        activityIndicatorView.center = view.center
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

    @objc private func keyboardDidShow(_ notification: Notification) {
        guard let editingTextField = editingTextField else { return }
        // キーボードのframeを調べる
        let userInfo = (notification as NSNotification).userInfo!
        // swiftlint:disable:next force_cast
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // テキストフィールドのframeをview座標で取得
        let textFieldFrame = view.convert(editingTextField.frame, from: editingTextField.superview)
        // 重なっている高さ
        let spaceOfTextFieldAndKeyboard: CGFloat = 8
        let overlap = textFieldFrame.maxY - keyboardFrame.minY + spaceOfTextFieldAndKeyboard

        if overlap > 0 {
            baseScrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        // スクロールを戻す
        baseScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    @objc func didTapKeyboardDoneButton() {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingTextField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
