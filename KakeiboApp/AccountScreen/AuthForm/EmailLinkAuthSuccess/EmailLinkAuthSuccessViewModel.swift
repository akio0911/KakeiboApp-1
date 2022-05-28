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
        authType.sendSignInLink(email: emailRelay.value) { _ in }
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
