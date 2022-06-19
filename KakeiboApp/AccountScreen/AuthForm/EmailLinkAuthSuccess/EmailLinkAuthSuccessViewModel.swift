//
//  EmailLinkAuthSuccessViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/13.
//

import Foundation
import RxSwift
import RxCocoa

protocol EmailLinkAuthSuccessViewModelInput {
    func didTapEmailResendButton()
    func didTapEmailChangeButton()
}

protocol EmailLinkAuthSuccessViewModelOutput {
    var email: Driver<String> { get }
    var event: Driver<EmailLinkAuthSuccessViewModel.Event> { get }
}

protocol EmailLinkAuthSuccessViewModelType {
    var inputs: EmailLinkAuthSuccessViewModelInput { get }
    var outputs: EmailLinkAuthSuccessViewModelOutput { get }
}

final class EmailLinkAuthSuccessViewModel: EmailLinkAuthSuccessViewModelInput, EmailLinkAuthSuccessViewModelOutput {
    enum Event {
        case popVC
        case presentAlertView(alertTitle: String, message: String)
        case startAnimating
        case stopAnimating
    }

    private let authType: AuthTypeProtocol
    private let emailRelay = BehaviorRelay<String>(value: "")
    private let eventRelay = PublishRelay<Event>()

    init(authType: AuthTypeProtocol = ModelLocator.shared.authType,
         email: String) {
        self.authType = authType
        emailRelay.accept(email)
    }

    var email: Driver<String> {
        emailRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapEmailResendButton() {
        eventRelay.accept(.stopAnimating)
        authType.sendSignInLink(email: emailRelay.value) { [weak self] error in
            self?.eventRelay.accept(.stopAnimating)
            if let error = error {
                // 再送信に失敗
                let alertTitle = error.reason ?? "再送信に失敗しました。"
                let message = error.message
                self?.eventRelay.accept(.presentAlertView(alertTitle: alertTitle, message: message))
            } else {
                // 再送信に成功
                let alertTitle = "メールを送信しました"
                let message = "メールを確認してパスワードを設定して下さい"
                self?.eventRelay.accept(.presentAlertView(alertTitle: alertTitle, message: message))
            }
        }
    }

    func didTapEmailChangeButton() {
        eventRelay.accept(.popVC)
    }
}

extension EmailLinkAuthSuccessViewModel: EmailLinkAuthSuccessViewModelType {
    var inputs: EmailLinkAuthSuccessViewModelInput {
        return self
    }

    var outputs: EmailLinkAuthSuccessViewModelOutput {
        return self
    }
}
