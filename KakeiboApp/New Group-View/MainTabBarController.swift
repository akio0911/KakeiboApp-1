//
//  MainTabBarController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/04.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
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

        let inputViewController = InputViewController()
        inputViewController.tabBarItem = UITabBarItem(
            title: "入力",
            image: UIImage(systemName: "pencil"),
            tag: 1
        )
        viewControllers.append(inputViewController)

        let graphViewController = GraphViewController()
        graphViewController.tabBarItem = UITabBarItem(
            title: "グラフ",
            image: UIImage(systemName: "chart.pie"),
            tag: 2
        )
        viewControllers.append(graphViewController)

        let navigationControllers =
            viewControllers.map {
                UINavigationController(rootViewController: $0)
            }
        setViewControllers(navigationControllers, animated: false)
    }
}
