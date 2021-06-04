//
//  CalendarListLayout.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/31.
//

import UIKit

struct CalendarListLayout {
    
    var monthData = [[IncomeAndExpenditure]]()

    mutating func loadMonthData(firstDay: Date, data: [IncomeAndExpenditure]) {
        monthData.removeAll()
        let calendar = Calendar(identifier: .gregorian)
        var dayData = [IncomeAndExpenditure]()
        let month = firstDay.string(dateFormat: "yyyy/MM")
        for i in 0...30{
            dayData.removeAll()
            let day = calendar.date(byAdding: .day, value: i, to: firstDay)
            for d in data {
                if d.date.string(dateFormat: "yyyy/MM") == month &&
                    d.date.string(dateFormat: "yyyy/MM/dd") == day!.string(dateFormat: "yyyy/MM/dd") {
                    dayData.append(d)
                }
            }
            if dayData.count != 0 { monthData.append(dayData)}
        }
    }
    
}

