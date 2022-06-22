//
//  EventBus.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/18.
//

import Foundation
import RxSwift

enum EventBus {
    case updatedUserInfo
    case setupData
    case setCategoryData
}

extension EventBus {
    var name: String {
        return "com.kyohei.KakeiboApp" + String(self.hashValue)
    }

    func post(_ param: EventParams? = nil) {
        var userInfo: [AnyHashable: Any]?
        if let eventParam = param {
            userInfo = [eventParam.key: eventParam]
        }
        NotificationCenter.default.post(
            name: Notification.Name(name),
            object: nil,
            userInfo: userInfo)
    }

    func asObservable() -> Observable<EventParams?> {
        return NotificationCenter.default
            .rx.notification(Notification.Name(name))
            .observe(on: MainScheduler.instance)
            .flatMap { notification -> Observable<EventParams?> in
                if let param = notification.userInfo?.first?.value as? EventParams {
                    return Observable.just(param)
                }
                return Observable.just(nil)
            }
    }
}

protocol EventParams {
    var key: String { get }
}

extension EventParams {
    var key: String { return "\(type(of: self))" }
}
