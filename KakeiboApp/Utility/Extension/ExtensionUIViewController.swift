//
//  ExtensionUIViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/18.
//

import Foundation
import UIKit

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
}
