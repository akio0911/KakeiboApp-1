//
//  HowToUseTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import UIKit

class HowToUseTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stateImageView: UIImageView!
    @IBOutlet private weak var underLineView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var messageLabelBottomConstraint: NSLayoutConstraint!

    private let closedImage = UIImage(systemName: "chevron.down")
    private let openedImage = UIImage(systemName: "chevron.up")

    func configure(item: HowToUseItem) {
        titleLabel.text = item.title
        switch item.isClosedMessage {
        case true:
            // cellが閉じている時
            stateImageView.image = closedImage
            underLineView.isHidden = true
            messageLabel.text = ""
            messageLabelBottomConstraint.constant = 0
        case false:
            // cellが開いている時
            stateImageView.image = openedImage
            underLineView.isHidden = false
            messageLabel.text = item.message
            messageLabelBottomConstraint.constant = 15
        }
    }
}
