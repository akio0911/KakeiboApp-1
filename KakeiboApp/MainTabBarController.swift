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
        showProgress()
        kakeiboModel.setupData(userId: userId) { [weak self] error in
            if error != nil {
                self?.hideProgress()
                self?.showErrorAlert()
            } else {
                self?.categoryModel.setupData(userId: userId) { [weak self] error in
                    self?.hideProgress()
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

        guard let calendarViewController = R.storyboard.calendar.instantiateInitialViewController() else {
            return
        }
        var calendarTabBarItem: UITabBarItem {
            let calendarTabBarItem = UITabBarItem(
                title: R.string.localizable.calendar(),
                image: UIImage(systemName: "calendar"),
                selectedImage: UIImage(systemName: "calendar")
            )
            return calendarTabBarItem
        }
        calendarViewController.tabBarItem = calendarTabBarItem
        viewControllers.append(calendarViewController)

        let graphViewController = GraphViewController()
        var graphTabBarItem: UITabBarItem {
            let graphTabBarItem = UITabBarItem(
                title: R.string.localizable.graph(),
                image: UIImage(systemName: "chart.pie"),
                selectedImage: UIImage(systemName: "chart.pie.fill")
            )
            return graphTabBarItem
        }
        graphViewController.tabBarItem = graphTabBarItem
        viewControllers.append(graphViewController)

        let accountViewController = AccountViewController()
        var accountTabBarItem: UITabBarItem {
            let accountTabBarItem = UITabBarItem(
                title: R.string.localizable.account(),
                image: UIImage(systemName: "person"),
                selectedImage: UIImage(systemName: "person.fill")
            )
            return accountTabBarItem
        }
        accountViewController.tabBarItem = accountTabBarItem
        viewControllers.append(accountViewController)

        let navigationControllers =
            viewControllers.map {
                UINavigationController(rootViewController: $0)
            }
        setViewControllers(navigationControllers, animated: false)
    }
}
