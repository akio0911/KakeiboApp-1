//
//  BackgroundHighlightedButton.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit

class BackgroundHighlightedButton: UIButton {
    @IBInspectable var highlightedBackgroundColor :UIColor?
    @IBInspectable var nonHighlightedBackgroundColor :UIColor?
    private let closedRange: ClosedRange<CGFloat> = 0...1
    @IBInspectable var alphaHighlited: CGFloat = 1
    override var isHighlighted :Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = highlightedBackgroundColor
                if closedRange.contains(alphaHighlited) {
                    self.alpha = alphaHighlited
                }
            }
            else {
                self.backgroundColor = nonHighlightedBackgroundColor
            }
        }
    }
}
