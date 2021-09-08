//
//  CalendarDateLocator.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import Foundation

// CalendarDateを共有するための構造体
struct CalendarDateLocator {
    static let shared = CalendarDateLocator()
    let calendarDate = CalendarDate()
    private init() {}
}
