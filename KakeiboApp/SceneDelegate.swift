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
    private let settingRepository: SettingsRepositoryProtocol =
    SettingsRepository()

    // アプリ起動時、sceneが呼ばれた時
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // NavigationBarの設定
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = R.color.sFFFFFF()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().barTintColor = R.color.s333333()
        UINavigationBar.appearance().tintColor = R.color.sFF9B00()

        // TabBarの設定
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = R.color.sFFFFFF()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        UITabBar.appearance().tintColor = R.color.s333333()

        let firebaseAuth = Auth.auth()
        if firebaseAuth.currentUser == nil {
            // ログアウト中
            // FireBaseの匿名認証
            ModelLocator.shared.authType.signInAnonymously { [weak self] _ in
                // 匿名認証の処理が返ってきた
                guard let strongSelf = self else { return }
                // 画面を表示する
                guard let windowScene = (scene as? UIWindowScene) else { return }
                strongSelf.window = UIWindow(windowScene: windowScene)
                let mainTabBarController = MainTabBarController()
                strongSelf.window?.rootViewController = mainTabBarController
                strongSelf.window?.makeKeyAndVisible()

                // パスコードが設定されていたら、パスコード画面表示する
                if strongSelf.settingRepository.isOnPasscode {
                    let passcodeViewController =
                    PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
                    passcodeViewController.modalPresentationStyle = .fullScreen
                    strongSelf.window?.rootViewController?.present(
                        passcodeViewController, animated: false, completion: nil
                    )
                }
            }
        } else {
            // ログイン中
            // 画面を表示する
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)
            let mainTabBarController = MainTabBarController()
            self.window?.rootViewController = mainTabBarController
            self.window?.makeKeyAndVisible()

            // パスコードが設定されていたら、パスコード画面表示する
            if settingRepository.isOnPasscode {
                let passcodeViewController =
                PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
                passcodeViewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.present(passcodeViewController, animated: false, completion: nil)
            }
        }
    }

    // DynamicLinksからアプリを起動した時
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let _ = ModelLocator.shared.authType.userInfo?.name else { return }
        let authFormViewController = AuthFormViewController(
            viewModel: AuthFormViewModel(mode: .setPassword)
        )
        let mainTabBarController = window?.rootViewController as? MainTabBarController
        let navigationController = mainTabBarController?.selectedViewController as? UINavigationController
        let topViewController = navigationController?.topViewController
        topViewController?.navigationController?.pushViewController(authFormViewController, animated: true)
    }

    // アプリがフォアグラウンドに来た時
    func sceneWillEnterForeground(_ scene: UIScene) {
        // パスコードが設定されていたら、生体認証を行う
        if settingRepository.isOnPasscode {
            let localAuthenticationContext = LAContext()
            var error: NSError?
            let reason: String // 生体認証を使用する理由
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // デバイスで生体認証が可能
                // 生体認証の種類を判定し、reasonを設定
                switch localAuthenticationContext.biometryType {
                case .none:
                    reason = R.string.localizable.biometryTypeNoneMessage()
                case .touchID:
                    reason = R.string.localizable.biometryTypeTouchIdMessage()
                case .faceID:
                    reason = R.string.localizable.biometryTypeFaceIdMessage()
                @unknown default:
                    reason = R.string.localizable.biometryTypeDefaultMessage()
                }
            } else {
                // デバイスで生体認証ができない
                if let error = error {
                    print("context.canEvaluatePolicy - Error, reason: \(error) ")
                }
                reason = R.string.localizable.biometryTypeNoneMessage()
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
            var topViewController = self.window?.rootViewController
            while topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController
            }
            let passcodeViewController = topViewController as! PasscodeViewController
            // swiftlint:disable:previous force_cast
            passcodeViewController.dismiss(animated: true, completion: nil)
        }
    }

    // アプリがバックグランドに移動した時
    func sceneDidEnterBackground(_ scene: UIScene) {
        // パスコードが設定されていたら、パスコード画面を表示する
        if settingRepository.isOnPasscode {
            var topViewController = window?.rootViewController
            while topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController
            }
            // すでにPasscodeViewControllerが表示されている場合、処理を終わらせる
            guard topViewController as? PasscodeViewController == nil else { return }
            let passcodeViewController =
            PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
            passcodeViewController.modalPresentationStyle = .fullScreen
            topViewController!.present(passcodeViewController, animated: false, completion: nil)
        }
    }
}
