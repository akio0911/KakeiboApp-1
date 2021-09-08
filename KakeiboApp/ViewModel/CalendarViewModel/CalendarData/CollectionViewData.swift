//
//  CollectionViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct FirstSectionItemData {
    let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
}

struct SecondSectionItemData {
    let stringDay: String // 日
    let stringTotalBalance: String // totalの収支

    init(date: Date, totalBalance: Int) {
        let stringDay = DateUtility.stringFromDate(date: date, format: "d")
        self.stringDay = stringDay
        let stringTotalBalance = totalBalance == 0 ? "" : String(totalBalance)
        self.stringTotalBalance = stringTotalBalance
    }
}
