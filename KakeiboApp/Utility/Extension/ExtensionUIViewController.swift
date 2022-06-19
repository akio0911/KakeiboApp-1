//
//  ExtensionUIViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/18.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController {
    func showAlert(title: String, messege: String, onAccept: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                onAccept?()
            }
        )
        present(alert, animated: true)
    }

    // TODO: エラーから文言を設定するよう修正
    func showErrorAlert(onError: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "データ取得に失敗しました", message: "電波の良い環境でやり直して下さい", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                onError?()
            }
        )
        present(alert, animated: true)
    }

    func showProgress() {
        MBProgressHUD.showAdded(to: view, animated: true)
    }

    func hideProgress() {
        MBProgressHUD.hide(for: view, animated: true)
    }
}
