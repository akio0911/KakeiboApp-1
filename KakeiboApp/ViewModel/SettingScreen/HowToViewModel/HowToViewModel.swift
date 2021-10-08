//
//  HowToViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import RxSwift
import RxRelay

protocol HowToViewModelInput {
    func didSelectRowAt(index: IndexPath)
}

protocol HowToViewModelOutput {
    var items: Observable<[HowToItem]> { get }
}

protocol HowToViewModelType {
    var inputs: HowToViewModelInput { get }
    var outputs: HowToViewModelOutput { get }
}

final class HowToViewModel: HowToViewModelInput, HowToViewModelOutput {

    private let itemsRelay = BehaviorRelay<[HowToItem]>(value: [])

    // テスト用
    private var testItems: [HowToItem] = [
        HowToItem(title: "test", message: "おやつカルパス", isClosedMessage: true),
        HowToItem(title: "test", message: "おやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパスおやつカルパス", isClosedMessage: true)
    ]

    init() {
        itemsRelay.accept(testItems)
    }

    var items: Observable<[HowToItem]> {
        itemsRelay.asObservable()
    }

    func didSelectRowAt(index: IndexPath) {
        testItems[index.row].isClosedMessage.toggle()
        itemsRelay.accept(testItems)
    }
}

extension HowToViewModel: HowToViewModelType {
    var inputs: HowToViewModelInput {
        return self
    }

    var outputs: HowToViewModelOutput {
        return self
    }
}
