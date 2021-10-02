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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Auth.auth().signInAnonymously(completion: { [weak self] userResult, error in
            print("Anonymouslyコールバック")
            guard let self = self else { return }
            if let error = error {
                print("Error 匿名認証に失敗しました \(error)")
            } else if let user = userResult?.user {
                let uid = user.uid
                print("匿名認証にせいこうしました \(uid)")
            }
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)
            let mainTabBarController = MainTabBarController()
            self.window?.rootViewController = mainTabBarController
            self.window?.makeKeyAndVisible()
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if passcodeRepository.loadIsOnPasscode() {
            let localAuthenticationContext = LAContext()
            var error: NSError?
            let reason: String
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
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
                if let error = error {
                    print("context.canEvaluatePolicy - Error, reason: \(error) ")
                }
                reason = "生体認証は使用しません"
            }
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
                        self.dismissPasscodeViewController()
                    } else {
                        // 認証失敗
                    }
                })
        }
    }

    private func dismissPasscodeViewController() {
        DispatchQueue.main.async {
            if let rootViewController = self.window?.rootViewController {
                let navigationController =
                rootViewController.presentedViewController as! UINavigationController
                let passcodeViewController =
                navigationController.topViewController as! PasscodeViewController
                passcodeViewController.dismiss(animated: true, completion: nil)
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        if passcodeRepository.loadIsOnPasscode() {
            if let rootViewController = window?.rootViewController {
                let passcodeViewController =
                PasscodeViewController(viewModel: PasscodeViewModel(mode: .unlock))
                let navigationController = UINavigationController(rootViewController: passcodeViewController)
                navigationController.modalPresentationStyle = .fullScreen
                rootViewController.present(navigationController, animated: false, completion: nil)
            }
        }
    }


}

