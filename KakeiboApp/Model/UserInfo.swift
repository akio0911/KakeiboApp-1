//
//  UserInfo.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/02.
//

import Foundation
import FirebaseAuth

struct UserInfo {
    let id: String // swiftlint:disable:this identifier_name
    let name: String?

    init?(user: User?) {
        guard let user = user else { return nil }
        id = user.uid
        name = user.displayName
    }
}
