//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import Foundation

protocol CalendarFrameDelegate: AnyObject {
    func calendarHeight(beforeNumberOfWeeks: Int, AfterNuberOfWeeks: Int)
}

class CalendarDate {
    
    weak var delegate: CalendarFrameDelegate?
    
    var days = [Date]()
    let weekday = ["日", "月", "火", "水", "木", "金", "土"]
    let carendar = Calendar(identifier: .gregorian)
    var today: Date!
    var carendarTitle: String!
    var nuberOfWeeks: Int!
    var selectDate: Date!
    
    var firstDay: Date! {
        didSet {
            carendarTitle = firstDay.string(dateFormat: "YYYY年MM月") 
            let beforeNumberOfWeeks = nuberOfWeeks
            days = setDays()
            if beforeNumberOfWeeks != nuberOfWeeks {
                delegate?.calendarHeight(beforeNumberOfWeeks: beforeNumberOfWeeks!, AfterNuberOfWeeks: nuberOfWeeks)
            }
        }
    }
    
    init() {
        let component = carendar.dateComponents([.year, .month, .day], from: Date())
        today = carendar.date(from: DateComponents(year: component.year, month: component.month, day: component.day))
        firstDay = carendar.date(from: DateComponents(year: component.year, month: component.month, day: 1))
        carendarTitle = firstDay.string(dateFormat: "YYYY年MM月")
        days = setDays()
    }
    
    private func setDays() -> [Date] {
        // 月の最初の曜日
        let firstWeekday = carendar.component(.weekday, from: firstDay)
        // 月の週の数
        let numberOfWeeks = carendar.range(of: .weekOfMonth, in: .month, for: firstDay)
        self.nuberOfWeeks = numberOfWeeks?.count
        // カレンダーに表示するItemの数
        let numberOfItems = numberOfWeeks!.count * 7
        
        return (1...numberOfItems).map { i in
            var dateComponents = DateComponents()
            dateComponents.day = i - firstWeekday
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
    }
    
    func nextMonth() {
        days.removeAll()
        firstDay = carendar.date(byAdding: .month, value: 1, to: firstDay)
    }
    
    func lastMonth() {
        days.removeAll()
        firstDay = carendar.date(byAdding: .month, value: -1, to: firstDay)
    }
}
