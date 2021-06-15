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
        for i in 0...30{
            dayData.removeAll()
            let day = calendar.date(byAdding: .day, value: i, to: firstDay)
            for d in data {
                if d.date == day {
                    dayData.append(d)
                }
            }
            if dayData.count != 0 { monthData.append(dayData)}
        }
    }
    
}

