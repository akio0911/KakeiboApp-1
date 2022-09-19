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
        showProgress()
        kakeiboModel.setupData(userId: authType.userInfo?.id) { [weak self] error in
            guard error == nil else {
                self?.hideProgress()
                self?.showErrorAlert()
                return
            }
            self?.categoryModel.setupData(userId: self?.authType.userInfo?.id) { [weak self] error in
                self?.hideProgress()
                guard error == nil else {
                    self?.showErrorAlert()
                    return
                }
                EventBus.setupData.post()
            }
        }
    }

    private func setupTabBarController() {
        let viewControllers = TabBarViews.allCases.compactMap { $0.viewController }
        let navigationControllers =
        viewControllers.map {
            UINavigationController(rootViewController: $0)
        }
        setViewControllers(navigationControllers, animated: false)
    }
}
