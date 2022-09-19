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

typealias AuthCompletion = (AuthError?) -> Void

protocol AuthTypeProtocol {
    var userInfo: UserInfo? { get }
    func registerUser(userName: String, email: String, completion: @escaping AuthCompletion)
    func signIn(email: String, password: String, completion: @escaping AuthCompletion)
    func sendPasswordReset(email: String, completion: @escaping AuthCompletion)
    func currentUserLink(password: String, completion: @escaping AuthCompletion)
    func sendSignInLink(email: String, completion: @escaping AuthCompletion)
    func accountDelete(completion: @escaping AuthCompletion)
}

final class AuthType: AuthTypeProtocol {
    private var actionCodeSettings: ActionCodeSettings!
    private let emailKey = "email"
    private(set) var userInfo: UserInfo?

    init() {
        let currentUser = Auth.auth().currentUser
        userInfo = UserInfo(user: currentUser)
        setupActionCode()
        EventBus.updatedUserInfo.post()
    }

    private func setupActionCode() {
        actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://kakeiboapp-22658.firebaseapp.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    }

    private func updateDisplayName(userName: String, email: String, completion: @escaping AuthCompletion) {
        // ユーザー名の設定
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = userName
        changeRequest.commitChanges { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                // ユーザー名の設定に失敗
                completion(AuthError(error: error))
            } else {
                // ユーザー名の設定に成功
                strongSelf.sendSignInLink(email: email, completion: completion)
            }
        }
    }

    func sendSignInLink(email: String, completion: @escaping AuthCompletion) {
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                // メールリンク送信に失敗
                completion(AuthError(error: error))
            } else {
                // メールリンク送信に成功
                UserDefaults.standard.set(email, forKey: strongSelf.emailKey)
                completion(nil)
            }
        }
    }

    func registerUser(userName: String, email: String, completion: @escaping AuthCompletion) {
        updateDisplayName(userName: userName, email: email, completion: completion)
    }

    func currentUserLink(password: String, completion: @escaping AuthCompletion) {
        guard let email = UserDefaults.standard.value(forKey: emailKey) as? String else {
            completion(AuthError.other(R.string.localizable.otherAuthError()))
            return
        }
        // 匿名アカウントを永久アカウントに変換
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.link(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // アカウント変換に失敗
                completion(AuthError(error: error))
            } else {
                // アカウント変換に成功
                guard let authResult = authResult else { return }
                strongSelf.userInfo = UserInfo(user: authResult.user)
                EventBus.updatedUserInfo.post()
                completion(nil)
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping AuthCompletion) {
        // メールアドレスとパスワードでログイン
        Auth.auth().signIn(withEmail: email,
                           password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // ログインに失敗
                completion(AuthError(error: error))
            } else {
                // ログインに成功
                strongSelf.userInfo = UserInfo(user: authResult?.user)
                EventBus.updatedUserInfo.post()
                completion(nil)
            }
        }
    }

    func sendPasswordReset(email: String, completion: @escaping AuthCompletion) {
        // 再設定メールを送信
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // 送信に失敗
                completion(AuthError(error: error))
            } else {
                // 送信に成功
                completion(nil)
            }
        }
    }

    func accountDelete(completion: @escaping AuthCompletion) {
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.delete { [weak self] error in
            if let error = error {
                // アカウント削除に失敗
                completion(AuthError(error: error))
            } else {
                // アカウント削除に成功
                self?.userInfo = nil
                EventBus.updatedUserInfo.post()
                completion(nil)
            }
        }
    }
}
