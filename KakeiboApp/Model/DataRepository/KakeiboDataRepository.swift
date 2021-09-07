//
//  KakeiboDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/06.
//

import Foundation
import RealmSwift

protocol KakeiboDataRepositoryProtocol {
    func loadData() -> [KakeiboData]
    func saveData(data: [KakeiboData])
}

final class KakeiboDataRepository: KakeiboDataRepositoryProtocol {

    private let realm = try! Realm()

    func loadData() -> [KakeiboData] {
        let data = realm.objects(KakeiboData.self)
        var kakeiboData: [KakeiboData] = []
        data.forEach { kakeiboData.append($0) }
        return kakeiboData
    }

    func saveData(data: [KakeiboData]) {
        try! realm.write {
            data.forEach {
                realm.add($0)
            }
        }
    }
}
