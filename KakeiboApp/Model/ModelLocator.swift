//
//  ModelLocator.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

final class ModelLocator {
    static let shared = ModelLocator()
    let model = KakeiboModel()
    let calendarDate = CalendarDate()
    var isOnPasscode = false // パスコード設定の状態
    private init() {}
}
