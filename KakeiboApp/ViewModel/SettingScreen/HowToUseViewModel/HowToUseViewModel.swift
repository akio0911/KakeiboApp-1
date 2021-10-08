//
//  HowToViewUseModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import RxSwift
import RxRelay

protocol HowToUseViewModelInput {
    func didSelectRowAt(index: IndexPath)
}

protocol HowToUseViewModelOutput {
    var items: Observable<[HowToUseItem]> { get }
}

protocol HowToUseViewModelType {
    var inputs: HowToUseViewModelInput { get }
    var outputs: HowToUseViewModelOutput { get }
}

final class HowToUseViewModel: HowToUseViewModelInput, HowToUseViewModelOutput {

    private let itemsRelay = BehaviorRelay<[HowToUseItem]>(value: [])

    // テスト用
    private var testItems: [HowToUseItem] = [
        HowToUseItem(title: "test", message: "おやつカルパス", isClosedMessage: true),
        HowToUseItem(title: "test", message: "おやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパス", isClosedMessage: true)
    ]

    init() {
        itemsRelay.accept(testItems)
    }

    var items: Observable<[HowToUseItem]> {
        itemsRelay.asObservable()
    }

    func didSelectRowAt(index: IndexPath) {
        testItems[index.row].isClosedMessage.toggle()
        itemsRelay.accept(testItems)
    }
}

extension HowToUseViewModel: HowToUseViewModelType {
    var inputs: HowToUseViewModelInput {
        return self
    }

    var outputs: HowToUseViewModelOutput {
        return self
    }
}
