//
//  HowToUseItem.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import Foundation

struct HowToUseItem {
    let title: String
    var message: String
    var isClosedMessage: Bool
}

enum HowToUseCase {
    case balanceInput // 収支の入力
    case balanceOfEditAndDeletion // 収支の編集と削除
    case changeCalendarMonth // カレンダーの月を変更
    case appearBalanceByCategory // カテゴリー別の収支を表示
    case passcodeSetting // パスコード設定
    case categoryEdit // カテゴリー編集

    var title: String {
        switch self {
        case .balanceInput:
            return "収支の入力"
        case .balanceOfEditAndDeletion:
            return "収支の編集と削除"
        case .changeCalendarMonth:
            return "カレンダーの月を変更"
        case .appearBalanceByCategory:
            return "カテゴリー別の収支を表示"
        case .passcodeSetting:
            return "パスコード設定"
        case .categoryEdit:
            return "カテゴリー編集"
        }
    }

    var message: String {
        switch self {
        case .balanceInput:
            return "収支の入力はカレンダー画面から行うことができます。\n"
            + "カレンダー画面には画面下のカレンダータブをタップして移動します。\n\n"
            + "カレンダー画面で日付をタップし、右上の入力ボタンをタップすると入力画面が表示されるので、そちらから各項目を入力して保存してください。"
        case .balanceOfEditAndDeletion:
            return "収支の編集と削除は、カレンダー画面から行うことができます。\n"
            + "カレンダー画面には画面下のカレンダータブをタップして移動します。\n\n"
            + "・収支の編集\n"
            + "カレンダー下の編集したい項目をタップすると編集画面が表示されるので、そちらから編集したい項目を変更し保存してください。\n\n"
            + "・収支の削除\n"
            + "カレンダー下の編集したい項目を左にスワイプすると削除ボタンが表示されるので、タップし削除してください。"
        case .changeCalendarMonth:
            return "カレンダーに表示されている月の両端に矢印ボタンがあります。矢印ボタンをタップするとカレンダーの月を変更できます。\n"
            + "左の矢印ボタンで、先月に変更します。\n"
            + "右の矢印ボタンで、翌月に変更します。"
        case .appearBalanceByCategory:
            return "カテゴリー別の収支は、グラフ画面から表示できます。\n"
            + "グラフ画面には画面下のグラフタブをタップして移動します。\n\n"
            + "グラフ下の表示したいカテゴリーをタップすると、カテゴリー別の収支が表示されます。"
        case .passcodeSetting:
            return "パスコード設定は、設定画面から行うことができます。\n"
            + "設定画面には画面下の設定タブをタップして移動します。\n\n"
            + "設定画面のパスコード設定をオンにするとパスコード設定画面が表示されるので、パスコードを設定してください。"
        case .categoryEdit:
            return "カテゴリーの編集は、設定画面から行うことができます。\n"
            + "設定画面には画面下の設定タブをタップして移動します。\n\n"
            + "設定画面のカテゴリー編集の項目をタップすると、カテゴリー編集画面が表示されます。\n"
            + "カテゴリー編集画面では、カテゴリーの追加、削除、編集を行うことができます。\n\n"
            + "・カテゴリーの追加\n"
            + "右上の追加ボタンをタップして、カテゴリー追加画面から追加が行えます。\n\n"
            + "・カテゴリーの削除\n"
            + "カテゴリーの項目をスワイプすると削除ボタンが表示されるので、タップし削除してください。\n\n"
            + "・カテゴリーの編集\n"
            + "カテゴリーの項目をタップするとカテゴリー編集画面が表示されるので、そちらから編集したい項目を変更し保存してください。"
        }
    }
}
