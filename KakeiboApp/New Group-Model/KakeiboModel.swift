//
//  KakeiboModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxRelay

protocol KakeiboModelProtocol {
    var dataObservable: Observable<[KakeiboData]> { get }
    func loadData(data: [KakeiboData])
    func addData(data: KakeiboData)
    func deleteData(index: Int)
    func updateData(index: Int, data: KakeiboData)
}

final class KakeiboModel: KakeiboModelProtocol {

    private let dataRelay = BehaviorRelay<[KakeiboData]>(value: [])

    var dataObservable: Observable<[KakeiboData]> {
        dataRelay.asObservable()
    }

    func loadData(data: [KakeiboData]) {
        dataRelay.accept(data)
    }

    func addData(data: KakeiboData) {
        var kakeiboData = dataRelay.value
        kakeiboData.append(data)
        dataRelay.accept(kakeiboData)
    }

    func deleteData(index: Int) {
        var kakeiboData = dataRelay.value
        kakeiboData.remove(at: index)
        dataRelay.accept(kakeiboData)
    }

    func updateData(index: Int, data: KakeiboData) {
        var kakeiboData = dataRelay.value
        kakeiboData[index] = data
        dataRelay.accept(kakeiboData)
    }
}
