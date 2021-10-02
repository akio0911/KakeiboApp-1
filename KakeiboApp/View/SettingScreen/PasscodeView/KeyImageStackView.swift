//
//  KeyImageStackView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/02.
//

import UIKit

final class KeyImageStackView: UIStackView {
    private var keyImageView1: UIImageView!
    private var keyImageView2: UIImageView!
    private var keyImageView3: UIImageView!
    private var keyImageView4: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        keyImageView1 = createKeyImageView()
        addArrangedSubview(keyImageView1)
        keyImageView2 = createKeyImageView()
        addArrangedSubview(keyImageView2)
        keyImageView3 = createKeyImageView()
        addArrangedSubview(keyImageView3)
        keyImageView4 = createKeyImageView()
        addArrangedSubview(keyImageView4)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createKeyImageView() -> UIImageView {
        let imageView = UIImageView()
        if #available(iOS 14.0, *) {
            imageView.image = UIImage(systemName: "key.fill")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .darkGray
            imageView.alpha = 0.5
        } else {
            imageView.image = UIImage(systemName: "bell.fill")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .darkGray
            imageView.alpha = 0.5
        }
        return imageView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        keyImageViewConstraint(imageView: keyImageView1)
        keyImageViewConstraint(imageView: keyImageView2)
        keyImageViewConstraint(imageView: keyImageView3)
        keyImageViewConstraint(imageView: keyImageView4)
    }

    private func keyImageViewConstraint(imageView: UIImageView) {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configureFirstKeyAlpha(alpha: CGFloat) {
        keyImageView1.alpha = alpha
    }

    func configureSecondKeyAlpha(alpha: CGFloat) {
        keyImageView2.alpha = alpha
    }

    func configureThirdKeyAlpha(alpha: CGFloat) {
        keyImageView3.alpha = alpha
    }

    func configureFourthKeyAlpha(alpha: CGFloat) {
        keyImageView4.alpha = alpha
    }

}
