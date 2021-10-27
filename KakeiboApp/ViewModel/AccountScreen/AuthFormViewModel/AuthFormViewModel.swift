//
//  AuthFormViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

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

    private let authForm: AuthFormProtocol
    let mode: Mode
    private let eventRelay = PublishRelay<Event>()
    private let disposeBag = DisposeBag()

    init(authForm: AuthFormProtocol = AuthForm(), mode: Mode) {
        self.authForm = authForm
        self.mode = mode
        setupBinding()
    }

    private func setupBinding() {
        authForm.authError
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.eventRelay.accept(.stopAnimating)
                let (alertTitle, message) = strongSelf.createErrorAlertText(error: error)
                strongSelf.eventRelay.accept(.presentErrorAlertView(alertTitle, message))
            })
            .disposed(by: disposeBag)

        authForm.authFormSuccess
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

    private func createErrorAlertText(error: Error) -> (String, String) {
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
        let errorCode = AuthErrorCode(rawValue: error._code)
        guard let errorCode = errorCode else { return (alertTitle,message) }
        switch errorCode {
        case .invalidEmail:
            // メールアドレスの形式が正しくないことを示します。
            alertTitle = "メールアドレスの形式が正しくありません。"
            message = "メールアドレスを正しく入力してください。"
        case .userDisabled:
            // ユーザーのアカウントが無効になっていることを示します。
            alertTitle = "無効なアカウントです。"
            message = "他のアカウントでログインしてください。"
        case .wrongPassword:
            // ユーザーが間違ったパスワードでログインしようとしたことを示します。
            alertTitle = "パスワードが一致しません。"
            message = "パスワードを正しく入力してください。"
        case .userNotFound:
            // ユーザーアカウントが見つからなかったことを示します。
            alertTitle = "アカウントが見つかりません。"
            message = "メールアドレスを正しく入力してください。"
        case .tooManyRequests:
            /* 呼び出し元の端末から Firebase Authenticationサーバーに
             異常な数のリクエストが行われた後で、リクエストがブロックされたことを示します。*/
            message = "しばらくしてからもう一度お試しください。"
        case .emailAlreadyInUse:
            // 登録に使用されたメールアドレスがすでに存在することを示します。
            alertTitle = "登録済みのメールアドレスです。"
            message = "ログイン画面からログインしてください。"
        case .weakPassword:
            // 設定しようとしたパスワードが弱すぎると判断されたことを示します。
            alertTitle = "パスワードが脆弱です。"
            message = "第三者から判定されづらいパスワードにしてください"
        default:
            message = error.localizedDescription
        }
        return (alertTitle, message)
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapEnterButton(userName: String, mail: String, password: String) {
        eventRelay.accept(.startAnimating)
        switch mode {
        case .login:
            authForm.signIn(mail: mail, password: password)
        case .create:
            guard userName != "" else {
                let alertTitle = "ユーザー名が未入力です。"
                let message = "ユーザー名を入力してください。"
                eventRelay.accept(.presentErrorAlertView(alertTitle, message))
                return
            }
            authForm.createUser(userName: userName, mail: mail, password: password)
        case .forgotPassword:
            authForm.sendPasswordReset(mail: mail)
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
