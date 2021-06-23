//
//  CalendarListLayout.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/31.
//

import UIKit

struct CalendarListLayout {
    
    private var monthData = [[IncomeAndExpenditure]]()

    mutating func loadMonthData(firstDay: Date, data: [IncomeAndExpenditure]) {
        monthData.removeAll()
        let calendar = Calendar(identifier: .gregorian)
        var dayData = [IncomeAndExpenditure]()
        for num in 0...30{
            dayData.removeAll()
            let day = calendar.date(byAdding: .day, value: num, to: firstDay)
            for data in data {
                if data.date == day {
                    dayData.append(data)
                }
            }
            if dayData.count != 0 { monthData.append(dayData)}
        }
    }

}

