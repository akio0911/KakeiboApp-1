//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import RxSwift
import RxRelay

protocol CalendarDateProtocol {
    var calendarDate: Observable<[Date]> { get } // calendarの日付
    var monthDate: Observable<[Date]> { get } // 月の日付
    var firstDay: Observable<Date> { get } // title(〇〇年〇〇月)
    func nextMonth()
    func lastMonth()
}

final class CalendarDate: CalendarDateProtocol {
    private let calendarDateRelay = BehaviorRelay<[Date]>(value: [])
    private let monthDateRelay = BehaviorRelay<[Date]>(value: [])
    private let firstDayRelay = BehaviorRelay<Date>(value: Date())
    private let carendar = Calendar(identifier: .gregorian)

    init() {
        let component = carendar.dateComponents([.year, .month], from: Date())
        guard let firstDay = carendar.date(
            from: DateComponents(year: component.year, month: component.month, day: 1)
        ) else { return }
        firstDayRelay.accept(firstDay)
        acceptDateArray(firstDay: firstDay)
    }

    var calendarDate: Observable<[Date]> {
           calendarDateRelay.asObservable()
       }

    var monthDate: Observable<[Date]> {
        monthDateRelay.asObservable()
    }

    var firstDay: Observable<Date> {
        firstDayRelay.asObservable()
    }

    private func acceptDateArray(firstDay: Date) {
        // 月の最初の曜日
        let firstWeekday = carendar.component(.weekday, from: firstDay)
        // 月の週の数
        guard let numberOfWeeks = carendar.range(
            of: .weekOfMonth, in: .month, for: firstDay
        ) else { return }
        // カレンダーに表示するItemの数
        let numberOfItems = numberOfWeeks.count * 7

        let calendarDateArray: [Date] = (1...numberOfItems).map { num in
            var dateComponents = DateComponents()
            dateComponents.day = num - firstWeekday
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
        calendarDateRelay.accept(calendarDateArray)

        let monthDateArray: [Date] = calendarDateArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0, toGranularity: .month)
        }
        monthDateRelay.accept(monthDateArray)
    }

    func nextMonth() {
        guard let firstDay = carendar.date(
            byAdding: .month, value: 1, to: firstDayRelay.value
        ) else { return }
        firstDayRelay.accept(firstDay)
        acceptDateArray(firstDay: firstDay)
    }

    func lastMonth() {
        guard let firstDay = carendar.date(
            byAdding: .month, value: -1, to: firstDayRelay.value
        ) else { return }
        firstDayRelay.accept(firstDay)
        acceptDateArray(firstDay: firstDay)
    }
}
