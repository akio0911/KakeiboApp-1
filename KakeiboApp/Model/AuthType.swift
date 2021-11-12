//
//  AuthType.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxRelay

protocol AuthTypeProtocol {
    var authError: Observable<AuthError?> { get }
    var authSuccess: Observable<Void> { get }
    var userInfo: Observable<UserInfo?> { get }
    func createUser(userName: String, mail: String, password: String)
    func signIn(mail: String, password: String)
    func sendPasswordReset(mail: String)
    func updateDisplayName(userName: String)
    func sendEmailVerification()
}

final class AuthType: AuthTypeProtocol {
    private let authErrorRelay = PublishRelay<AuthError?>()
    private let authSuccessRelay = PublishRelay<Void>()
    private let userInfoRelay = BehaviorRelay<UserInfo?>(value: nil)

    init() {
        let currentUser = Auth.auth().currentUser
        let userInfo = UserInfo(user: currentUser)
        userInfoRelay.accept(userInfo)
    }

    var authError: Observable<AuthError?> {
        authErrorRelay.asObservable()
    }

    var authSuccess: Observable<Void> {
        authSuccessRelay.asObservable()
    }

    var userInfo: Observable<UserInfo?> {
        userInfoRelay.asObservable()
    }

    private func currentUserLink(userName: String, mail: String, password: String) {
        // 匿名アカウントを永久アカウントに変換
        let credential = EmailAuthProvider.credential(withEmail: mail, password: password)
        Auth.auth().currentUser?.link(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // アカウント変換に失敗
                strongSelf.authErrorRelay.accept(AuthError(error: error))
                return
            }
            // アカウント変換に成功
            guard let authResult = authResult else { return }
            let userInfo = UserInfo(user: authResult.user)
            strongSelf.userInfoRelay.accept(userInfo)
            strongSelf.updateDisplayName(userName: userName)
        }
    }

    func sendEmailVerification() {
        guard let currentUser = Auth.auth().currentUser else { return }
        // 確認メールの送信
        currentUser.sendEmailVerification { [weak self] error in
            guard let strongSelf = self else { return }
            if error != nil {
                // 確認メール送信失敗
                strongSelf.authErrorRelay.accept(AuthError.failureSendEmailVerification)
            } else {
                // 確認メール送信成功
                let userInfo = UserInfo(user: currentUser)
                strongSelf.userInfoRelay.accept(userInfo)
                strongSelf.authSuccessRelay.accept(())
            }
        }
    }

    func updateDisplayName(userName: String) {
        // ユーザー名の設定
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = userName
        changeRequest.commitChanges { [weak self] error in
            guard let strongSelf = self else { return }
            if error != nil {
                // ユーザー名の設定に失敗
                strongSelf.authErrorRelay.accept(AuthError.failureUpdateDisplayName)
                return
            }
            // ユーザー名の設定に成功
            strongSelf.sendEmailVerification()
        }
    }

    func createUser(userName: String, mail: String, password: String) {
        currentUserLink(userName: userName, mail: mail, password: password)
    }

    func signIn(mail: String, password: String) {
        // メールアドレスとパスワードでログイン
        Auth.auth().signIn(withEmail: mail,
                           password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // ログインに失敗
                strongSelf.authErrorRelay.accept(AuthError(error: error))
            } else {
                // ログインに成功
                strongSelf.authSuccessRelay.accept(())
                let userInfo = UserInfo(user: authResult?.user)
                strongSelf.userInfoRelay.accept(userInfo)
            }
        }
    }

    func sendPasswordReset(mail: String) {
        // 再設定メールを送信
        Auth.auth().sendPasswordReset(withEmail: mail) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                // 送信に失敗
                strongSelf.authErrorRelay.accept(AuthError(error: error))
            } else {
                // 送信に成功
                strongSelf.authSuccessRelay.accept(())
            }
        }
    }
}
