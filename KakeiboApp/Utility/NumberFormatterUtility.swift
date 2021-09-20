//
//  NumberFormatterUtility.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/20.
//

import Foundation

struct NumberFormatterUtility {
    static func changeToCurrencyNotation(from: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyPlural
        numberFormatter.locale = Locale(identifier: "ja_JP")
        let value = NSNumber(integerLiteral: from)
        return numberFormatter.string(from: value)
    }
}
