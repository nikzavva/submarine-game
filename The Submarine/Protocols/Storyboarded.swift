//
//  Storyboarded.swift
//  The Submarine
//
//  Created by Николай Завгородний on 21.07.2025.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let className = String(describing: self)
        guard let vc = storyboard.instantiateViewController(withIdentifier: className) as? Self else { fatalError() }
        return vc
    }
}
