//
//  ModelLocator.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

// modelを共有するための構造体
struct ModelLocator {
    static let shared = ModelLocator()
    let model = KakeiboModel()
    let calendarDate = CalendarDate()
    private init() {}
}
