//
//  String+extension.swift
//  The Submarine
//
//  Created by Николай Завгородний on 10.09.2025.
//

import Foundation

extension String {
    func localize() -> String {
        NSLocalizedString(self, comment: "")
    }
}
