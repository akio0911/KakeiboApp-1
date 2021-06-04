//
//  extensionDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import Foundation

extension Date {
    
    func string(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}

//
