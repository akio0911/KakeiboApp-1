//
//  DateUtility.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import Foundation

final class DateUtility {
    static func dateFromString(stringDate: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: stringDate)!
    }
}
