//
//  StoreError.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/09.
//

import Foundation

enum StoreError: Error {
    case some(reason: String)

    init(error: Error) {
        self = .some(reason: error.localizedDescription)
    }
}
