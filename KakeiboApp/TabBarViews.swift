//
//  TabBarViews.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/31.
//

import Foundation
import UIKit
import SwiftUI

enum TabBarViews: Int, CaseIterable {
    case calendarView
    case inputView
    case graphView
    case accountView
}

extension TabBarViews {
    var viewController: UIViewController? {
        switch self {
        case .calendarView:
            return instantiateCalendarViewController()
        case .inputView:
            return instantiateInputViewController()
        case .graphView:
            return instantiateGraphViewController()
        case .accountView:
            return instantiateAccountViewController()
        }
    }

    private func instantiateCalendarViewController() -> UIViewController? {
        guard let calendarViewController = R.storyboard.calendar.instantiateInitialViewController() else {
            return nil
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
        return calendarViewController
    }

    private func instantiateInputViewController() -> UIViewController? {
        guard let inputViewController = R.storyboard.input.instantiateInitialViewController() else {
            return nil
        }

        var inputTabBarItem: UITabBarItem {
            let inputTabBarItem = UITabBarItem(
                title: R.string.localizable.balanceInput(),
                image: UIImage(systemName: "pencil"),
                selectedImage: UIImage(systemName: "pencil")
            )
            return inputTabBarItem
        }
        inputViewController.tabBarItem = inputTabBarItem
        return inputViewController
    }

    private func instantiateGraphViewController() -> UIViewController {
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
        return graphViewController
    }

    private func instantiateAccountViewController() -> UIViewController {
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
        return accountViewController
    }
}
