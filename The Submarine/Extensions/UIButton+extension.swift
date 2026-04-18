//
//  UIButton+extension.swift
//  The Submarine
//
//  Created by Николай Завгородний on 01.08.2025.
//

import UIKit

extension UIButton {
    func setTitle(_ text: String, withMultiplier multiplier: CGFloat = 0.5) {
        let size = min(bounds.height, bounds.width) * multiplier

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        setAttributedTitle(attributed, for: .normal)
    }

    func round(cornerRadius: CGFloat? = nil) {
        let radius = cornerRadius ?? bounds.height / 2
        layer.cornerRadius = radius
    }
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowRadius = 15
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        // Растеризация
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
    }
    
    func addGradient(_ colors: [CGColor]) {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.opacity = 1
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradient, at: 0)
    }
}
