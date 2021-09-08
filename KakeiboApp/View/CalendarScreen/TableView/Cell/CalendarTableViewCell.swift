//
//  CalendarTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet private weak var balanceImageView: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var memoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(data: CellDateKakeiboData) {
        balanceImageView.image = UIImage(named: data.imageName)
        categoryLabel.text = data.stringCategory
        balanceLabel.text = data.stringBalance
        memoLabel.text = data.memo
    }
}
