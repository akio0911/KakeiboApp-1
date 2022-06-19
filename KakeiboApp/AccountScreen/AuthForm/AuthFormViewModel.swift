//
//  AuthFormViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol AuthFormViewModelInput {
    func didTapEnterButton(userName: String, email: String, password: String)
    func didTapCancelButtton()
    func didTapForgotPasswordButton()
}

protocol AuthFormViewModelOutput {
    var event: Driver<AuthFormViewModel.Event> { get }
    var mode: AuthFormViewModel.Mode { get }
}

protocol AuthFormViewModelType {
    var inputs: AuthFormViewModelInput { get }
    var outputs: AuthFormViewModelOutput { get }
}

final class AuthFormViewModel: AuthFormViewModelInput, AuthFormViewModelOutput {
    enum Event {
        case presentErrorAlertView(alertTitle: String, message: String)
        case presentPopVCAlertView(alertTitle: String, message: String)
        case pushEmailLinkAuthSuccess(email: String)
        case popToRootVC
        case popVC
        case pushAuthFormForgotPasswordMode
        case startAnimating
        case stopAnimating
    }

    enum Mode {
        case login
        case forgotPassword
        case register
        case setPassword
    }

    private let authType: AuthTypeProtocol
    let mode: Mode
    private let eventRelay = PublishRelay<Event>()
    private let disposeBag = DisposeBag()

    init(authType: AuthTypeProtocol = ModelLocator.shared.authType, mode: Mode) {
        self.authType = authType
        self.mode = mode
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapEnterButton(userName: String, email: String, password: String) {
        switch mode {
        case .login:
            login(email: email, password: password)
        case .forgotPassword:
            forgotPassword(email: email)
        case .register:
            guard !userName.isEmpty else {
                let alertTitle = "ユーザー名が未入力です。"
                let message = "ユーザー名を入力してください。"
                eventRelay.accept(.presentErrorAlertView(alertTitle: alertTitle, message: message))
                return
            }
            register(userName: userName, email: email)
        case .setPassword:
            setPassword(password: password)
        }
    }

    private func login(email: String, password: String) {
        eventRelay.accept(.startAnimating)
        authType.signIn(email: email, password: password) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.eventRelay.accept(.stopAnimating)
            if let error = error {
                // ログインに失敗
                let alertTitle = error.reason ?? "ログインに失敗しました。"
                let message = error.message
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle: alertTitle, message: message))
            } else {
                // ログインに成功
                strongSelf.eventRelay.accept(.popVC)
            }
        }
    }

    private func forgotPassword(email: String) {
        // 再設定メールを送信
        eventRelay.accept(.startAnimating)
        authType.sendPasswordReset(email: email) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.eventRelay.accept(.stopAnimating)
            if let error = error {
                // 送信に失敗
                let alertTitle = error.reason ?? "再設定メールの送信に失敗しました。"
                let message = error.message
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle: alertTitle, message: message))
            } else {
                // 送信に成功
                let alertTitle = "再設定メールを送信しました。"
                let message = "メールを確認し、パスワードの再設定を行ってください。"
                strongSelf.eventRelay.accept(.presentPopVCAlertView(alertTitle: alertTitle, message: message))
            }
        }
    }

    private func register(userName: String, email: String) {
        eventRelay.accept(.startAnimating)
        authType.registerUser(userName: userName, email: email) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.eventRelay.accept(.stopAnimating)
            if let error = error {
                // 登録に失敗
                let alertTitle = error.reason ?? "登録に失敗しました。"
                let message = error.message
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle: alertTitle, message: message))
            } else {
                // 登録に成功
                strongSelf.eventRelay.accept(.pushEmailLinkAuthSuccess(email: email))
            }
        }
    }

    private func setPassword(password: String) {
        eventRelay.accept(.startAnimating)
        authType.currentUserLink(password: password) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.eventRelay.accept(.stopAnimating)
            if let error = error {
                // 登録に失敗
                let alertTitle = error.reason ?? "登録に失敗しました。"
                let message = error.message
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle: alertTitle, message: message))
            } else {
                // 登録に成功
                strongSelf.eventRelay.accept(.popToRootVC)
            }
        }
    }

    func didTapCancelButtton() {
        switch mode {
        case .login, .forgotPassword, .register:
            eventRelay.accept(.popVC)
        case .setPassword:
            eventRelay.accept(.popToRootVC)
        }
    }

    func didTapForgotPasswordButton() {
        eventRelay.accept(.pushAuthFormForgotPasswordMode)
    }
}

extension AuthFormViewModel: AuthFormViewModelType {
    var inputs: AuthFormViewModelInput {
        return self
    }

    var outputs: AuthFormViewModelOutput {
        return self
    }
}
