//
//  ExtensionUICollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/05.
//

import UIKit

extension UICollectionViewCell {

    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self),
                                  bundle: nil) }
}
