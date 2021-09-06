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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let stringDay =
            dateFormatter.string(from: date)
        self.stringDay = stringDay
        self.stringTotalBalance = String(totalBalance)
    }
}