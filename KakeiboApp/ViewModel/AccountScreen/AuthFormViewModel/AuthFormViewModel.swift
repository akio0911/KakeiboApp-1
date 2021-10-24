//
//  AuthFormViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol AuthFormLoginModeViewModelInput {
    func login(email: String, password: String)
    func didTapForgotPasswordButton()
}

protocol AuthFormLoginModeViewModelOutput {
    var event: Driver<AuthFormLoginModeViewModel.Event> { get }
}

protocol AuthFormLoginModeViewModelType {
    var inputs: AuthFormLoginModeViewModelInput { get }
    var outputs: AuthFormLoginModeViewModelOutput { get }
}

final class AuthFormLoginModeViewModel: AuthFormLoginModeViewModelInput, AuthFormLoginModeViewModelOutput {
    enum Event {
        case dismiss
        case presentAlertView(String, String) // (alertTitle, message)
        case pushUserFormForgotPasswordMode
    }

    private let eventRelay = PublishRelay<Event>()

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func login(email: String, password: String) {
        // TODO: ログイン処理を実装
    }

    func didTapForgotPasswordButton() {
        eventRelay.accept(.pushUserFormForgotPasswordMode)
    }
}

extension AuthFormLoginModeViewModel: AuthFormLoginModeViewModelType {
    var inputs: AuthFormLoginModeViewModelInput {
        return self
    }

    var outputs: AuthFormLoginModeViewModelOutput {
        return self
    }
}
