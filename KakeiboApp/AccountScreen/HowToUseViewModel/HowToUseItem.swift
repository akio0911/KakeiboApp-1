//
//  HowToUseItem.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import Foundation

struct HowToUseItem {
    let title: String
    var message: String
    var isClosedMessage: Bool
}

enum HowToUseCase {
    case balanceInput // 収支の入力
    case balanceOfEditAndDeletion // 収支の編集と削除
    case changeCalendarMonth // カレンダーの月を変更
    case appearBalanceByCategory // カテゴリー別の収支を表示
    case passcodeSetting // パスコード設定
    case categoryEdit // カテゴリー編集

    var title: String {
        switch self {
        case .balanceInput:
            return R.string.localizable.balanceInputTitle()
        case .balanceOfEditAndDeletion:
            return R.string.localizable.balanceOfEditAndDeletionTitle()
        case .changeCalendarMonth:
            return R.string.localizable.changeCalendarMonthTitle()
        case .appearBalanceByCategory:
            return R.string.localizable.appearBalanceByCategoryTitle()
        case .passcodeSetting:
            return R.string.localizable.passcodeSettingTitle()
        case .categoryEdit:
            return R.string.localizable.categoryEditTitle()
        }
    }

    var message: String {
        switch self {
        case .balanceInput:
            return R.string.localizable.balanceInputMessage()
        case .balanceOfEditAndDeletion:
            return R.string.localizable.balanceOfEditAndDeletionMessage()
        case .changeCalendarMonth:
            return R.string.localizable.changeCalendarMonthMessage()
        case .appearBalanceByCategory:
            return R.string.localizable.appearBalanceByCategoryMessage()
        case .passcodeSetting:
            return R.string.localizable.passcodeSettingMessage()
        case .categoryEdit:
            return R.string.localizable.categoryEditMessage()
        }
    }
}
