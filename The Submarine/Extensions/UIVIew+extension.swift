//
//  UIVIew+extension.swift
//  The Submarine
//
//  Created by Николай Завгородний on 01.08.2025.
//

import UIKit

extension UIView {
    func createLabel() -> UILabel {
        let label = UILabel()
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        addSubview(label)
        return label
    }
}
