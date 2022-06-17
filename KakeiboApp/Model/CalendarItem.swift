//
//  CalendarItem.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct CalendarItem {
    let date: Date
    let totalBalance: Int
    let isCalendarMonth: Bool
    let dataArray: [(CategoryData, KakeiboData)]
}
