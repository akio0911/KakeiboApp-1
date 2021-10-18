//
//  CollectionViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct WeekdayItemData {
    let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
}

struct DayItemData {
    let date: Date // 日付
    let totalBalance: Int // totalの収支
    let isCalendarMonth: Bool // カレンダーの表示月であるか
}
