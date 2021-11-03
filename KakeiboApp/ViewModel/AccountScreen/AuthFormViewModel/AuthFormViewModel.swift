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
    func didTapEnterButton(userName: String, mail: String, password: String)
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
        case dismiss
        case presentErrorAlertView(String, String) // (alertTitle, message)
        case presentDismissAlertView(String, String) // (alertTitle, message)
        case presentPopVCAlertView(String, String) // (alertTitle, message)
        case pushAuthFormForgotPasswordMode
        case popVC
        case startAnimating
        case stopAnimating
    }

    enum Mode {
        case login
        case create
        case forgotPassword
    }

    private let authType: AuthTypeProtocol
    let mode: Mode
    private let eventRelay = PublishRelay<Event>()
    private let disposeBag = DisposeBag()

    init(authType: AuthTypeProtocol = ModelLocator.shared.authType, mode: Mode) {
        self.authType = authType
        self.mode = mode
        setupBinding()
    }

    private func setupBinding() {
        authType.authError
            .subscribe(onNext: { [weak self] authError in
                guard let strongSelf = self else { return }
                strongSelf.eventRelay.accept(.stopAnimating)
                let (alertTitle, message) = strongSelf.createErrorAlertText(authError: authError)
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle, message))
            })
            .disposed(by: disposeBag)

        authType.authSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.eventRelay.accept(.stopAnimating)
                switch strongSelf.mode {
                case .login:
                    strongSelf.eventRelay.accept(.dismiss)
                case .create:
                    let alertTitle = "入力されたメールアドレス宛に確認メールを送信しました。"
                    let message = ""
                    strongSelf.eventRelay.accept(.presentDismissAlertView(alertTitle, message))
                case .forgotPassword:
                    let alertTitle = "再設定メールを送信しました。"
                    let message = "メールを確認し、パスワードの再設定を行ってください。"
                    strongSelf.eventRelay.accept(.presentPopVCAlertView(alertTitle, message))
                }
            })
            .disposed(by: disposeBag)
    }

    private func createErrorAlertText(authError: AuthError?) -> (String, String) {
        var alertTitle: String
        switch mode {
        case .login:
            alertTitle = "ログインに失敗しました。"
        case .create:
            alertTitle = "アカウント登録に失敗しました。"
        case .forgotPassword:
            alertTitle = "再設定メールの送信に失敗しました。"
        }
        var message = ""
        guard let authError = authError else {
            return (alertTitle, message)
        }
        if let reason = authError.reason {
            alertTitle = reason
        }
        message = authError.message
        return (alertTitle, message)
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapEnterButton(userName: String, mail: String, password: String) {
        eventRelay.accept(.startAnimating)
        switch mode {
        case .login:
            authType.signIn(mail: mail, password: password)
        case .create:
            guard userName != "" else {
                let alertTitle = "ユーザー名が未入力です。"
                let message = "ユーザー名を入力してください。"
                eventRelay.accept(.presentErrorAlertView(alertTitle, message))
                return
            }
            authType.createUser(userName: userName, mail: mail, password: password)
        case .forgotPassword:
            authType.sendPasswordReset(mail: mail)
        }
    }

    func didTapCancelButtton() {
        switch mode {
        case .login, .create:
            eventRelay.accept(.dismiss)
        case .forgotPassword:
            eventRelay.accept(.popVC)
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
