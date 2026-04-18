//
//  RoundResults.swift
//  The Submarine
//
//  Created by Николай Завгородний on 27.08.2025.
//

struct RoundResultsData: Codable {
    var resultsSixtySeconds: [RoundResultData] = []
    var resultsThirtySeconds: [RoundResultData] = []
    var resultsTenSeconds: [RoundResultData] = []
}
