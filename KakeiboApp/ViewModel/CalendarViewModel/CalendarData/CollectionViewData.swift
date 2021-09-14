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
    let stringDay: String // 日
    let stringTotalBalance: String // totalの収支
    let isCalendarMonth: Bool // カレンダーの表示月であるか

    init(date: Date, totalBalance: Int, firstDay: Date) {
        let stringDay = DateUtility.stringFromDate(date: date, format: "d")
        self.stringDay = stringDay
        let stringTotalBalance = totalBalance == 0 ? "" : String(totalBalance)
        self.stringTotalBalance = stringTotalBalance
        isCalendarMonth = Calendar(identifier: .gregorian)
            .isDate(firstDay, equalTo: date, toGranularity: .year)
            && Calendar(identifier: .gregorian)
            .isDate(firstDay, equalTo: date, toGranularity: .month)
    }
}
