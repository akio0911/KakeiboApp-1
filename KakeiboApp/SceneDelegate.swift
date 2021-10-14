//
//  SceneDelegate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let passcodeRepository: IsOnPasscodeRepositoryProtocol =
    PasscodeRepository()

    // アプリ起動時、sceneが呼ばれた時
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // FireBaseの匿名認証
        Auth.auth().signInAnonymously(completion: { [weak self] userResult, error in
            // 匿名認証の処理が返ってきた
            guard let self = self else { return }
            if let error = error {
                print("Error 匿名認証に失敗しました \(error)")
            } else if let user = userResult?.user {
                let uid = user.uid
                print("匿名認証に成功しました \(uid)")
            }

            // 画面を表示する
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)
            let mainTabBarController = MainTabBarController()
            self.window?.rootViewController = mainTabBarController
            self.window?.makeKeyAndVisible()

            // パスコードが設定されていたら、パスコード画面表示する
            if self.passcodeRepository.loadIsOnPasscode() {
                let passcodeViewController =
                PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
                passcodeViewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.present(passcodeViewController, animated: false, completion: nil)
            }
        })
    }

    // アプリがフォアグラウンドに来た時
    func sceneWillEnterForeground(_ scene: UIScene) {
        // パスコードが設定されていたら、生体認証を行う
        if passcodeRepository.loadIsOnPasscode() {
            let localAuthenticationContext = LAContext()
            var error: NSError?
            let reason: String // 生体認証を使用する理由
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // デバイスで生体認証が可能
                // 生体認証の種類を判定し、reasonを設定
                switch localAuthenticationContext.biometryType {
                case .none:
                    reason = "生体認証は使用しません"
                case .touchID:
                    reason = "ロック解除のためTouchIDを使用します。"
                case .faceID:
                    reason = "ロック解除のためFaceIDを使用します。"
                @unknown default:
                    reason = "新しい生体認証を使用します"
                }
            } else {
                // デバイスで生体認証ができない
                if let error = error {
                    print("context.canEvaluatePolicy - Error, reason: \(error) ")
                }
                reason = "生体認証は使用しません"
            }

            // 生体認証を実行
            localAuthenticationContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason,
                reply: { [weak self] success, error in
                    guard let self = self else { return }
                    if let error = error {
                        print("context.evaluatePolicy - Error, reason: \(error) ")
                    }
                    if success {
                        // 認証成功
                        // passcodeViewControllerを閉じる
                        self.dismissPasscodeViewController()
                    }
                }
            )
        }
    }

    // passcodeViewControllerを閉じる
    private func dismissPasscodeViewController() {
        DispatchQueue.main.async {
            if let rootViewController = self.window?.rootViewController {
                let passcodeViewController =
                rootViewController.presentedViewController as! PasscodeViewController
                passcodeViewController.dismiss(animated: true, completion: nil)
            }
        }
    }

    // アプリがバックグランドに移動した時
    func sceneDidEnterBackground(_ scene: UIScene) {
        // パスコードが設定されていたら、パスコード画面を表示する
        if passcodeRepository.loadIsOnPasscode() {
            if let rootViewController = window?.rootViewController {
                let passcodeViewController =
                PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
                passcodeViewController.modalPresentationStyle = .fullScreen
                rootViewController.present(passcodeViewController, animated: false, completion: nil)
            }
        }
    }
}

