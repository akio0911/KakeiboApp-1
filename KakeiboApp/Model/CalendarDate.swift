//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import RxSwift
import RxRelay

protocol CalendarDateProtocol {
    func loadCalendarDate(year: Int, month: Int, isContainOtherMonth: Bool) -> [Date]
}

final class CalendarDate: CalendarDateProtocol {
    private let calendar = Calendar(identifier: .gregorian)

    func loadCalendarDate(year: Int, month: Int, isContainOtherMonth: Bool) -> [Date] {
        // 指定した年月の一日（ついたち）と　月の週の数　と　月の日数
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let numberOfWeek = calendar.range(of: .weekOfMonth, in: .month, for: firstDay),
              let numberOfDay = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }

        if isContainOtherMonth {
            // 月の最初の曜日
            let firstWeekday = calendar.component(.weekday, from: firstDay)
            // カレンダーに表示するItemの数
            let numberOfItems = numberOfWeek.count * 7
            // 他の月を含めたDate配列
            let calendarDateArray: [Date] = (1...numberOfItems).map { num in
                let dateComponents = DateComponents(year: year, month: month, day: num - (firstWeekday - 1))
                return calendar.date(from: dateComponents)!
            }
            return calendarDateArray
        } else {
            // 他の月を含まないDate配列
            let calendarDateArray: [Date] = numberOfDay.map { num in
                let dateComponents = DateComponents(year: year, month: month, day: num)
                return calendar.date(from: dateComponents)!
            }
            return calendarDateArray
        }
    }
}
