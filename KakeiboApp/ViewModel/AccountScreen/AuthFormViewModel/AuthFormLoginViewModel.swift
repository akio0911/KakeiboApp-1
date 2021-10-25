//
//  AuthFormLoginViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

protocol AuthFormLoginViewModelInput {
    func login(email: String, password: String)
    func didTapForgotPasswordButton()
}

protocol AuthFormLoginViewModelOutput {
    var event: Driver<AuthFormLoginViewModel.Event> { get }
}

protocol AuthFormLoginViewModelType {
    var inputs: AuthFormLoginViewModelInput { get }
    var outputs: AuthFormLoginViewModelOutput { get }
}

final class AuthFormLoginViewModel: AuthFormLoginViewModelInput, AuthFormLoginViewModelOutput {
    enum Event {
        case dismiss
        case presentAlertView(String, String) // (alertTitle, message)
        case pushUserFormForgotPasswordMode
    }

    private let eventRelay = PublishRelay<Event>()
    private let authForm: AuthFormProtocol
    private let disposeBag = DisposeBag()

    init(authForm: AuthFormProtocol = AuthForm()) {
        self.authForm = authForm
        setupBinding()
    }

    private func setupBinding() {
        authForm.authError
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                let (alertTitle, message) = strongSelf.createAlertText(error: error)
                strongSelf.eventRelay.accept(.presentAlertView(alertTitle, message))
            })
            .disposed(by: disposeBag)

        authForm.authFormSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.eventRelay.accept(.dismiss)
            })
            .disposed(by: disposeBag)
    }

    private func createAlertText(error: Error) -> (String, String) {
        var alertTitle = "ログインに失敗しました。"
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
            message = "アカウントを新規作成してください。"
        case .tooManyRequests:
            // 呼び出し元の端末から Firebase Authentication サーバーに異常な数のリクエストが行われた後で、リクエストがブロックされたことを示します。
            message = "しばらくしてからもう一度お試しください。"
        default:
            message = error.localizedDescription
        }
        return (alertTitle, message)
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func login(email: String, password: String) {
        authForm.signIn(mail: email, password: password)
    }

    func didTapForgotPasswordButton() {
        eventRelay.accept(.pushUserFormForgotPasswordMode)
    }
}

extension AuthFormLoginViewModel: AuthFormLoginViewModelType {
    var inputs: AuthFormLoginViewModelInput {
        return self
    }

    var outputs: AuthFormLoginViewModelOutput {
        return self
    }
}
