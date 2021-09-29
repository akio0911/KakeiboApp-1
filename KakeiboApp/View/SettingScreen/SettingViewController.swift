//
//  SettingViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit

class SettingViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "設定"
    }
}
