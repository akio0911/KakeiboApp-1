//
//  MainTabBarController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/04.
//

import UIKit
import RxSwift

final class MainTabBarController: UITabBarController {
    private let authType: AuthTypeProtocol
    private let kakeiboModel: KakeiboModelProtocol
    private let categoryModel: CategoryModelProtocol
    private let disposeBag = DisposeBag()

    init(authType: AuthTypeProtocol = ModelLocator.shared.authType,
         kakeiboModel: KakeiboModelProtocol = ModelLocator.shared.kakeiboModel,
         categoryModel: CategoryModelProtocol = ModelLocator.shared.categoryModel) {
        self.authType = authType
        self.kakeiboModel = kakeiboModel
        self.categoryModel = categoryModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupData()
        setupTabBarController()
    }

    private func setupBinding() {
        EventBus.updatedUserInfo.asObservable()
            .subscribe { [weak self] _ in
                self?.setupData()
            }
            .disposed(by: disposeBag)
    }

    private func setupData() {
        guard let userId = authType.userInfo?.id else {
            return
        }
        // TODO: インジケータの表示ロジックを追加
        kakeiboModel.setupData(userId: userId) { [weak self] error in
            if error != nil {
                self?.showErrorAlert()
            } else {
                self?.categoryModel.setupData(userId: userId) { [weak self] error in
                    if error != nil {
                        self?.showErrorAlert()
                    } else {
                        EventBus.setupData.post()
                    }
                }
            }
        }
    }

    private func setupTabBarController() {
        var viewControllers: [UIViewController] = []

        let calendarViewController = CalendarViewController()
        calendarViewController.tabBarItem = UITabBarItem(
            title: "カレンダー",
            image: UIImage(systemName: "calendar"),
            tag: 0
        )
        viewControllers.append(calendarViewController)

        let graphViewController = GraphViewController()
        graphViewController.tabBarItem = UITabBarItem(
            title: "グラフ",
            image: UIImage(systemName: "chart.pie"),
            tag: 1
        )
        viewControllers.append(graphViewController)

        let accountViewController = AccountViewController()
        accountViewController.tabBarItem = UITabBarItem(
            title: "アカウント",
            image: UIImage(systemName: "person"),
            tag: 2
        )
        viewControllers.append(accountViewController)

        let navigationControllers =
            viewControllers.map {
                UINavigationController(rootViewController: $0)
            }
        setViewControllers(navigationControllers, animated: false)
    }
}
