//
//  ExtensionString.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/31.
//

import Foundation

extension String {

    func date(dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)!
    }
}
