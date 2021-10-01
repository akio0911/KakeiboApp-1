//
//  PasscodeObserver.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import Foundation

final class PasscodePoster {
    static let passcodeViewDidTapCancelButton = Notification.Name("passcodeViewDidTapCancelButton")

    func didTapCancelButtonPost() {
        NotificationCenter.default.post(
            name: PasscodePoster.passcodeViewDidTapCancelButton, object: nil)
    }
}
