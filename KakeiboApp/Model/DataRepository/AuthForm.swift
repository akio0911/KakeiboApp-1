//
//  AuthForm.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxRelay

protocol AuthFormProtocol {
    var authError: Observable<AuthError?> { get }
    var authSuccess: Observable<Void> { get }
    func createUser(userName: String, mail: String, password: String)
    func signIn(mail: String, password: String)
    func sendPasswordReset(mail: String)
}

final class AuthForm: AuthFormProtocol {
    private let authErrorRelay = PublishRelay<AuthError?>()
    private let authSuccessRelay = PublishRelay<Void>()

    var authError: Observable<AuthError?> {
        authErrorRelay.asObservable()
    }

    var authSuccess: Observable<Void> {
        authSuccessRelay.asObservable()
    }

    func createUser(userName: String, mail: String, password: String) {
        // 匿名アカウントを永久アカウントに変換
        // クレデンシャルを作成
        let credential = EmailAuthProvider.credential(withEmail: mail, password: password)
        // アカウントを作成
        Auth.auth().currentUser?.link(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            // アカウント作成に失敗
            if let error = error {
                strongSelf.authErrorRelay.accept(AuthError(error: error))
                return
            }

            // アカウント作成に成功
            guard let authResult = authResult else { return }

            // ユーザー名の設定
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = userName
            changeRequest.commitChanges { error in
                // ユーザー名の設定に失敗
                if let error = error {
                    strongSelf.authErrorRelay.accept(AuthError(error: error))
                    return
                }

                // ユーザー名の設定に成功
                // 確認メールの送信
                authResult.user.sendEmailVerification{ error in
                    if let error = error {
                        // 確認メール送信失敗
                        strongSelf.authErrorRelay.accept(AuthError(error: error))
                    } else {
                        // 確認メール送信成功
                        strongSelf.authSuccessRelay.accept(())
                    }
                }
            }
        }
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
