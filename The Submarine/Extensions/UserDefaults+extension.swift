//
//  UserDefaults+extension.swift
//  The Submarine
//
//  Created by Николай Завгородний on 11.08.2025.
//

import Foundation

extension UserDefaults {
    func saveSettings(_ settings: SettingsData) {
        if let encoded = try? JSONEncoder().encode(settings) {
            set(encoded, forKey: Key.settings)
        }
    }

    func loadSettings() -> SettingsData? {
        guard let data = data(forKey: Key.settings),
              let decoded = try? JSONDecoder().decode(SettingsData.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func saveRoundResults(_ results: RoundResultsData) {
        if let encoded = try? JSONEncoder().encode(results) {
            set(encoded, forKey: Key.results)
        }
    }
    
    func loadRoundResults() -> RoundResultsData {
        guard let data = data(forKey: Key.results),
              let decoded = try? JSONDecoder().decode(RoundResultsData.self, from: data) else {
            return RoundResultsData()
        }
        return decoded
    }
}

private enum Key {
    static let settings = "SettingsData"
    static let results = "RoundResults"
}
