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
    private let itemsRelay = BehaviorRelay<[HowToUseItem]>(value: [
        HowToUseItem(title: HowToUseCase.balanceInput.title,
                     message: HowToUseCase.balanceInput.message,
                     isClosedMessage: true),
        HowToUseItem(title: HowToUseCase.balanceOfEditAndDeletion.title,
                     message: HowToUseCase.balanceOfEditAndDeletion.message,
                     isClosedMessage: true),
        HowToUseItem(title: HowToUseCase.changeCalendarMonth.title,
                     message: HowToUseCase.changeCalendarMonth.message,
                     isClosedMessage: true),
        HowToUseItem(title: HowToUseCase.appearBalanceByCategory.title,
                     message: HowToUseCase.appearBalanceByCategory.message,
                     isClosedMessage: true),
        HowToUseItem(title: HowToUseCase.passcodeSetting.title,
                     message: HowToUseCase.passcodeSetting.message,
                     isClosedMessage: true),
        HowToUseItem(title: HowToUseCase.categoryEdit.title,
                     message: HowToUseCase.categoryEdit.message,
                     isClosedMessage: true)
    ])

    var items: Observable<[HowToUseItem]> {
        itemsRelay.asObservable()
    }

    func didSelectRowAt(index: IndexPath) {
        var items = itemsRelay.value
        items[index.row].isClosedMessage.toggle()
        itemsRelay.accept(items)
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
