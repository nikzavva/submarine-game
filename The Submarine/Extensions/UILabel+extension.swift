//
//  UILabel+extension.swift
//  The Submarine
//
//  Created by Николай Завгородний on 01.08.2025.
//

import UIKit

extension UILabel {
    func setText(_ text: String, baseSize: CGFloat = 38) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: baseSize, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        let attributed = NSAttributedString(string: text, attributes: attributes)
        attributedText = attributed
    }
    
    
}
