//
//  main.swift
//  nba-stats
//
//  Created by Cesar Muro on 5/25/20.
//  Copyright © 2020 Cesar Muro. All rights reserved.
//
import Foundation
import CSV

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let draftrequest = try? newJSONDecoder().decode(DraftRequest.self, from: jsonData)

// MARK: - DraftRequest
class DraftRequest: Codable {
    let resultSets: [ResultSet]
    
    init(resultSets: [ResultSet]) {
        self.resultSets = resultSets
    }
}

// MARK: - ResultSet
class ResultSet: Codable {
    let name: String
    let headers: [String]
    let rowSet: [[RowSet]]
    
    init(name: String, headers: [String], rowSet: [[RowSet]]) {
        self.name = name
        self.headers = headers
        self.rowSet = rowSet
    }
}

enum RowSet: Codable {
    case integer(Int)
    case string(String)
    case double(Double)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        print("PEPEInit")
        throw DecodingError.typeMismatch(RowSet.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RowSet"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
        
        print("PEPEncode")
    }
}

func draftHistory() {
    
    let semaphore = DispatchSemaphore (value: 0)
    
    var year = 1947
    
    while (year < 2021)
    {
        
        var request = URLRequest(url: URL(string: "https://stats.nba.com/stats/drafthistory?LeagueID=00&Season=\(year)&TeamID=0")!,timeoutInterval: Double.infinity)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("stats", forHTTPHeaderField: "x-nba-stats-origin")
        request.addValue("true", forHTTPHeaderField: "x-nba-stats-token")
        //request.addValue("VQECWF5UChAHUlNTBwgBVw==", forHTTPHeaderField: "X-NewRelic-ID")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("stats.nba.com", forHTTPHeaderField: "Host")
        request.addValue("https://stats.nba.com/draft/history/?Season=\(year)", forHTTPHeaderField: "Referer")
        //request.addValue("ak_bmsc=14065B3D6929CD05FE7B07D35E4AB2AF1738AC6697240000DCCECB5EA637AD73~pl/klUFmxcxhhpmPc3Wqe8ouw9vafUBuE2yTuythL9FGP3DTmPLZ+1hEEjtTJa7BAvs/kRDUZ5ievx5th38eUMsQfhgaDoezFONrjIWPOYc2Ihgch12gKCUzmOAipV28OBL4vzZDRg4zC82zN9AGhLBAANMCdSzkO7EqL4CwT1riEo/C6I83UhBUW/lMZq5EtglFKKnk4rCiqeir8z5QGQaw9zlJyPSJ1QSrmWs0Onhx4=; bm_sv=FFC8872539CE3EC2F6FAD4C91FA87119~CVcs/8TV+yoqtbjO3wWQVw0Y58bXgZ873WYy9utmft6ptX/pbiJTZN3n8EiZXWNdZpBgus8k9ET8dsz7HUfOjYdloLZhujbxu31oGDgnk66/1L/jJ7NQDGlju/vHGpycI7o6UXKANU4P4v91Zqq05Q==", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do
            {
                let stream = OutputStream(toFileAtPath: "./Draft_picks_\(year).csv", append: false)!
                let csv = try! CSVWriter(stream: stream)
                try! csv.write(row: [
                    "PERSON_ID",
                    "PLAYER_NAME",
                    "SEASON",
                    "ROUND_NUMBER",
                    "ROUND_PICK",
                    "OVERALL_PICK",
                    "DRAFT_TYPE",
                    "TEAM_ID",
                    "TEAM_CITY",
                    "TEAM_NAME",
                    "TEAM_ABBREVIATION",
                    "ORGANIZATION",
                    "ORGANIZATION_TYPE"
                ])
                let drafthistory = try? JSONDecoder().decode(DraftRequest.self, from: data)
                //    [
                //        "PERSON_ID",
                //        "PLAYER_NAME",
                //        "SEASON",
                //        "ROUND_NUMBER",
                //        "ROUND_PICK",
                //        "OVERALL_PICK",
                //        "DRAFT_TYPE",
                //        "TEAM_ID",
                //        "TEAM_CITY",
                //        "TEAM_NAME",
                //        "TEAM_ABBREVIATION",
                //        "ORGANIZATION",
                //        "ORGANIZATION_TYPE"
                //    ]
                
                //    [
                //        1629627,
                //        "Zion Williamson",
                //        "2019",
                //        1,
                //        1,
                //        1,
                //        "Draft",
                //        1610612740,
                //        "New Orleans",
                //        "Pelicans",
                //        "NOP",
                //        "Duke",
                //        "College/University"
                //    ]
                for player in drafthistory!.resultSets[0].rowSet {
                    csv.beginNewRow()
                    switch player[0] {
                    case let .integer(id):
                        print("id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[1] {
                    case let .string(name):
                        print("name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[2] {
                    case let .string(string):
                        print("season is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[3] {
                    case let .integer(integer):
                        print("round number is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[4] {
                    case let .integer(integer):
                        print("round pick is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[5] {
                    case let .integer(integer):
                        print("overall pick is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[6] {
                    case let .string(string):
                        print("draft type is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[7] {
                    case let .integer(integer):
                        print("team_id is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[8] {
                    case let .string(string):
                        print("team city is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[9] {
                    case let .string(string):
                        print("team_name is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[10] {
                    case let .string(string):
                        print("team abbreviation is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[11] {
                    case let .string(string):
                        print("organization is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[12] {
                    case let .string(string):
                        print("organization_type is...  \(string)")
                        try! csv.write(field: string)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                }
                csv.stream.close()
                //     print(drafthistory!.resultSets[0].rowSet)
            }
            catch {
                print("CSV error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        year+=1
    }
}

func draftSpotUp() {
    let semaphore = DispatchSemaphore (value: 0)
    
    var year = 2000
    
    while (year < 2021)
    {
        var mySubstring = String(String(year).suffix(2))
        var endYear:Int = Int(mySubstring)!
        endYear = endYear + 1
        mySubstring = String(endYear)
        if (endYear < 10)
        {
            mySubstring = "0\(endYear)"
        }
        var request = URLRequest(url: URL(string: "https://stats.nba.com/stats/draftcombinespotshooting?LeagueID=00&SeasonYear=\(year)-\(mySubstring)")!,timeoutInterval: Double.infinity)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("stats", forHTTPHeaderField: "x-nba-stats-origin")
        request.addValue("true", forHTTPHeaderField: "x-nba-stats-token")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("stats.nba.com", forHTTPHeaderField: "Host")
        request.addValue("https://stats.nba.com/draft/combine-spot-up/", forHTTPHeaderField: "Referer")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do
            {
                let stream = OutputStream(toFileAtPath: "./Draft_spot_up_\(year).csv", append: false)!
                let csv = try! CSVWriter(stream: stream)
                try! csv.write(row: [
                    "TEMP_PLAYER_ID",
                    "PLAYER_ID",
                    "FIRST_NAME",
                    "LAST_NAME",
                    "PLAYER_NAME",
                    "POSITION",
                    "FIFTEEN_CORNER_LEFT_MADE",
                    "FIFTEEN_CORNER_LEFT_ATTEMPT",
                    "FIFTEEN_CORNER_LEFT_PCT",
                    "FIFTEEN_BREAK_LEFT_MADE",
                    "FIFTEEN_BREAK_LEFT_ATTEMPT",
                    "FIFTEEN_BREAK_LEFT_PCT",
                    "FIFTEEN_TOP_KEY_MADE",
                    "FIFTEEN_TOP_KEY_ATTEMPT",
                    "FIFTEEN_TOP_KEY_PCT",
                    "FIFTEEN_BREAK_RIGHT_MADE",
                    "FIFTEEN_BREAK_RIGHT_ATTEMPT",
                    "FIFTEEN_BREAK_RIGHT_PCT",
                    "FIFTEEN_CORNER_RIGHT_MADE",
                    "FIFTEEN_CORNER_RIGHT_ATTEMPT",
                    "FIFTEEN_CORNER_RIGHT_PCT",
                    "COLLEGE_CORNER_LEFT_MADE",
                    "COLLEGE_CORNER_LEFT_ATTEMPT",
                    "COLLEGE_CORNER_LEFT_PCT",
                    "COLLEGE_BREAK_LEFT_MADE",
                    "COLLEGE_BREAK_LEFT_ATTEMPT",
                    "COLLEGE_BREAK_LEFT_PCT",
                    "COLLEGE_TOP_KEY_MADE",
                    "COLLEGE_TOP_KEY_ATTEMPT",
                    "COLLEGE_TOP_KEY_PCT",
                    "COLLEGE_BREAK_RIGHT_MADE",
                    "COLLEGE_BREAK_RIGHT_ATTEMPT",
                    "COLLEGE_BREAK_RIGHT_PCT",
                    "COLLEGE_CORNER_RIGHT_MADE",
                    "COLLEGE_CORNER_RIGHT_ATTEMPT",
                    "COLLEGE_CORNER_RIGHT_PCT",
                    "NBA_CORNER_LEFT_MADE",
                    "NBA_CORNER_LEFT_ATTEMPT",
                    "NBA_CORNER_LEFT_PCT",
                    "NBA_BREAK_LEFT_MADE",
                    "NBA_BREAK_LEFT_ATTEMPT",
                    "NBA_BREAK_LEFT_PCT",
                    "NBA_TOP_KEY_MADE",
                    "NBA_TOP_KEY_ATTEMPT",
                    "NBA_TOP_KEY_PCT",
                    "NBA_BREAK_RIGHT_MADE",
                    "NBA_BREAK_RIGHT_ATTEMPT",
                    "NBA_BREAK_RIGHT_PCT",
                    "NBA_CORNER_RIGHT_MADE",
                    "NBA_CORNER_RIGHT_ATTEMPT",
                    "NBA_CORNER_RIGHT_PCT"
                ])

                let draftSpotUp = try? JSONDecoder().decode(DraftRequest.self, from: data)

                for player in draftSpotUp!.resultSets[0].rowSet {
                    csv.beginNewRow()
                    switch player[0] {
                    case let .integer(id):
                        print("team player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[1] {
                    case let .integer(id):
                        print("player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[2] {
                    case let .string(name):
                        print("first name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[3] {
                    case let .string(name):
                        print("last name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[4] {
                    case let .string(name):
                        print("player name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[5] {
                    case let .string(name):
                        print("position is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[6] {
                    case let .integer(integer):
                        print("FIFTEEN_CORNER_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[7] {
                    case let .integer(integer):
                        print("FIFTEEN_CORNER_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[8] {
                    case let .double(double):
                        print("FIFTEEN_CORNER_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                        
                    }
                    switch player[9] {
                    case let .integer(integer):
                        print("FIFTEEN_BREAK_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[10] {
                    case let .integer(integer):
                        print("FIFTEEN_BREAK_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[11] {
                    case let .double(double):
                        print("FIFTEEN_BREAK_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[12] {
                    case let .integer(integer):
                        print("FIFTEEN_TOP_KEY_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[13] {
                    case let .integer(integer):
                        print("FIFTEEN_TOP_KEY_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[14] {
                    case let .double(double):
                        print("FIFTEEN_TOP_KEY_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[15] {
                    case let .integer(integer):
                        print("FIFTEEN_BREAK_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[16] {
                    case let .integer(integer):
                        print("FIFTEEN_BREAK_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[17] {
                    case let .double(double):
                        print("FIFTEEN_BREAK_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[18] {
                    case let .integer(integer):
                        print("FIFTEEN_CORNER_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[19] {
                    case let .integer(integer):
                        print("FIFTEEN_CORNER_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[20] {
                    case let .double(double):
                        print("FIFTEEN_CORNER_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[21] {
                    case let .integer(integer):
                        print("COLLEGE_CORNER_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[22] {
                    case let .integer(integer):
                        print("COLLEGE_CORNER_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[23] {
                    case let .double(double):
                        print("COLLEGE_CORNER_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[24] {
                    case let .integer(integer):
                        print("COLLEGE_BREAK_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[25] {
                    case let .integer(integer):
                        print("COLLEGE_BREAK_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[26] {
                    case let .double(double):
                        print("COLLEGE_BREAK_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[27] {
                    case let .integer(integer):
                        print("COLLEGE_TOP_KEY_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[28] {
                    case let .integer(integer):
                        print("COLLEGE_TOP_KEY_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[29] {
                    case let .double(double):
                        print("COLLEGE_TOP_KEY_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[30] {
                    case let .integer(integer):
                        print("COLLEGE_BREAK_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[31] {
                    case let .integer(integer):
                        print("COLLEGE_BREAK_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[32] {
                    case let .double(double):
                        print("COLLEGE_BREAK_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[33] {
                    case let .integer(integer):
                        print("COLLEGE_CORNER_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[34] {
                    case let .integer(integer):
                        print("COLLEGE_CORNER_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[35] {
                    case let .double(double):
                        print("COLLEGE_CORNER_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[36] {
                    case let .integer(integer):
                        print("NBA_CORNER_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[37] {
                    case let .integer(integer):
                        print("NBA_CORNER_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[38] {
                    case let .double(double):
                        print("NBA_CORNER_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[39] {
                    case let .integer(integer):
                        print("NBA_BREAK_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[40] {
                    case let .integer(integer):
                        print("NBA_BREAK_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[41] {
                    case let .double(double):
                        print("NBA_BREAK_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[42] {
                    case let .integer(integer):
                        print("NBA_TOP_KEY_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[43] {
                    case let .integer(integer):
                        print("NBA_TOP_KEY_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[44] {
                    case let .double(double):
                        print("NBA_TOP_KEY_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[45] {
                    case let .integer(integer):
                        print("NBA_BREAK_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[46] {
                    case let .integer(integer):
                        print("NBA_BREAK_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[47] {
                    case let .double(double):
                        print("NBA_BREAK_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[48] {
                    case let .integer(integer):
                        print("NBA_CORNER_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[49] {
                    case let .integer(integer):
                        print("NBA_CORNER_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[50] {
                    case let .double(double):
                        print("NBA_CORNER_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                   
                }
                do {
                    sleep(1)
                }
                csv.stream.close()
                //     print(drafthistory!.resultSets[0].rowSet)
            }
            catch {
                print("CSV error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        year+=1
    }
    
}

func draftNonStationary()
{
    let semaphore = DispatchSemaphore (value: 0)
    
    var year = 2000
    
    while (year < 2021)
    {
        var mySubstring = String(String(year).suffix(2))
        var endYear:Int = Int(mySubstring)!
        endYear = endYear + 1
        mySubstring = String(endYear)
        if (endYear < 10)
        {
            mySubstring = "0\(endYear)"
        }
        var request = URLRequest(url: URL(string: "https://stats.nba.com/stats/draftcombinenonstationaryshooting?LeagueID=00&SeasonYear=\(year)-\(mySubstring)")!,timeoutInterval: Double.infinity)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("stats", forHTTPHeaderField: "x-nba-stats-origin")
        request.addValue("true", forHTTPHeaderField: "x-nba-stats-token")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("stats.nba.com", forHTTPHeaderField: "Host")
        request.addValue("https://stats.nba.com/draft/combine-non-stationary/", forHTTPHeaderField: "Referer")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do
            {
                let stream = OutputStream(toFileAtPath: "./Draft_non_stationary_\(year).csv", append: false)!
                let csv = try! CSVWriter(stream: stream)
                try! csv.write(row: [
                    "TEMP_PLAYER_ID",
                    "PLAYER_ID",
                    "FIRST_NAME",
                    "LAST_NAME",
                    "PLAYER_NAME",
                    "POSITION",
                    "OFF_DRIB_FIFTEEN_BREAK_LEFT_MADE",
                    "OFF_DRIB_FIFTEEN_BREAK_LEFT_ATTEMPT",
                    "OFF_DRIB_FIFTEEN_BREAK_LEFT_PCT",
                    "OFF_DRIB_FIFTEEN_TOP_KEY_MADE",
                    "OFF_DRIB_FIFTEEN_TOP_KEY_ATTEMPT",
                    "OFF_DRIB_FIFTEEN_TOP_KEY_PCT",
                    "OFF_DRIB_FIFTEEN_BREAK_RIGHT_MADE",
                    "OFF_DRIB_FIFTEEN_BREAK_RIGHT_ATTEMPT",
                    "OFF_DRIB_FIFTEEN_BREAK_RIGHT_PCT",
                    "OFF_DRIB_COLLEGE_BREAK_LEFT_MADE",
                    "OFF_DRIB_COLLEGE_BREAK_LEFT_ATTEMPT",
                    "OFF_DRIB_COLLEGE_BREAK_LEFT_PCT",
                    "OFF_DRIB_COLLEGE_TOP_KEY_MADE",
                    "OFF_DRIB_COLLEGE_TOP_KEY_ATTEMPT",
                    "OFF_DRIB_COLLEGE_TOP_KEY_PCT",
                    "OFF_DRIB_COLLEGE_BREAK_RIGHT_MADE",
                    "OFF_DRIB_COLLEGE_BREAK_RIGHT_ATTEMPT",
                    "OFF_DRIB_COLLEGE_BREAK_RIGHT_PCT",
                    "ON_MOVE_FIFTEEN_MADE",
                    "ON_MOVE_FIFTEEN_ATTEMPT",
                    "ON_MOVE_FIFTEEN_PCT",
                    "ON_MOVE_COLLEGE_MADE",
                    "ON_MOVE_COLLEGE_ATTEMPT",
                    "ON_MOVE_COLLEGE_PCT"
                ])

                let draftSpotUp = try? JSONDecoder().decode(DraftRequest.self, from: data)

                for player in draftSpotUp!.resultSets[0].rowSet {
                    csv.beginNewRow()
                    switch player[0] {
                    case let .integer(id):
                        print("team player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[1] {
                    case let .integer(id):
                        print("player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[2] {
                    case let .string(name):
                        print("first name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[3] {
                    case let .string(name):
                        print("last name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[4] {
                    case let .string(name):
                        print("player name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[5] {
                    case let .string(name):
                        print("position is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[6] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_BREAK_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[7] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_BREAK_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[8] {
                    case let .double(double):
                        print("OFF_DRIB_FIFTEEN_BREAK_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[9] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_TOP_KEY_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[10] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_TOP_KEY_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[11] {
                    case let .double(double):
                        print("OFF_DRIB_FIFTEEN_TOP_KEY_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                      case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[12] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_BREAK_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[13] {
                    case let .integer(integer):
                        print("OFF_DRIB_FIFTEEN_BREAK_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[14] {
                    case let .double(double):
                        print("OFF_DRIB_FIFTEEN_BREAK_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[15] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_BREAK_LEFT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[16] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_BREAK_LEFT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[17] {
                    case let .double(double):
                        print("OFF_DRIB_COLLEGE_BREAK_LEFT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[18] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_TOP_KEY_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[19] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_TOP_KEY_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[20] {
                    case let .double(double):
                        print("OFF_DRIB_COLLEGE_TOP_KEY_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[21] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_BREAK_RIGHT_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[22] {
                    case let .integer(integer):
                        print("OFF_DRIB_COLLEGE_BREAK_RIGHT_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[23] {
                    case let .double(double):
                        print("OFF_DRIB_COLLEGE_BREAK_RIGHT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[24] {
                    case let .integer(integer):
                        print("ON_MOVE_FIFTEEN_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[25] {
                    case let .integer(integer):
                        print("ON_MOVE_FIFTEEN_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[26] {
                    case let .double(double):
                        print("ON_MOVE_FIFTEEN_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[27] {
                    case let .integer(integer):
                        print("ON_MOVE_COLLEGE_MADE is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[28] {
                    case let .integer(integer):
                        print("ON_MOVE_COLLEGE_ATTEMPT is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[29] {
                    case let .double(double):
                        print("ON_MOVE_COLLEGE_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                }
                do {
                    sleep(1)
                }
                csv.stream.close()
                //     print(drafthistory!.resultSets[0].rowSet)
            }
            catch {
                print("CSV error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        year+=1
    }
}

func draftStrengthAgility()
{
    let semaphore = DispatchSemaphore (value: 0)
    
    var year = 2000
    
    while (year < 2021)
    {
        var mySubstring = String(String(year).suffix(2))
        var endYear:Int = Int(mySubstring)!
        endYear = endYear + 1
        mySubstring = String(endYear)
        if (endYear < 10)
        {
            mySubstring = "0\(endYear)"
        }
        var request = URLRequest(url: URL(string: "https://stats.nba.com/stats/draftcombinedrillresults?LeagueID=00&SeasonYear=\(year)-\(mySubstring)")!,timeoutInterval: Double.infinity)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("stats", forHTTPHeaderField: "x-nba-stats-origin")
        request.addValue("true", forHTTPHeaderField: "x-nba-stats-token")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("stats.nba.com", forHTTPHeaderField: "Host")
        request.addValue("https://stats.nba.com/draft/combine-strength-agility/", forHTTPHeaderField: "Referer")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do
            {
                let stream = OutputStream(toFileAtPath: "./Draft_non_stationary_\(year).csv", append: false)!
                let csv = try! CSVWriter(stream: stream)
                try! csv.write(row: [
                    "TEMP_PLAYER_ID",
                    "PLAYER_ID",
                    "FIRST_NAME",
                    "LAST_NAME",
                    "PLAYER_NAME",
                    "POSITION",
                    "STANDING_VERTICAL_LEAP",
                    "MAX_VERTICAL_LEAP",
                    "LANE_AGILITY_TIME",
                    "MODIFIED_LANE_AGILITY_TIME",
                    "THREE_QUARTER_SPRINT",
                    "BENCH_PRESS"
                ])

                let draftSpotUp = try? JSONDecoder().decode(DraftRequest.self, from: data)

                for player in draftSpotUp!.resultSets[0].rowSet {
                    csv.beginNewRow()
                    switch player[0] {
                    case let .integer(id):
                        print("team player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[1] {
                    case let .integer(id):
                        print("player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[2] {
                    case let .string(name):
                        print("first name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[3] {
                    case let .string(name):
                        print("last name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[4] {
                    case let .string(name):
                        print("player name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[5] {
                    case let .string(name):
                        print("position is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[6] {
                    case let .double(double):
                        print("STANDING_VERTICAL_LEAP is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[7] {
                    case let .double(double):
                        print("MAX_VERTICAL_LEAP is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[8] {
                    case let .double(double):
                        print("LANE_AGILITY_TIME is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[9] {
                    case let .double(double):
                        print("MODIFIED_LANE_AGILITY_TIME is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[10] {
                    case let .double(double):
                        print("THREE_QUARTER_SPRINT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[11] {
                    case let .integer(integer):
                        print("BENCH_PRESS is...  \(integer)")
                        try! csv.write(field: String(integer))
                    case .string(_):
                        break
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
           
                }
                do {
                    sleep(1)
                }
                csv.stream.close()
                //     print(drafthistory!.resultSets[0].rowSet)
            }
            catch {
                print("CSV error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        year+=1
    }
}

func draftAntro()
{
    let semaphore = DispatchSemaphore (value: 0)
    
    var year = 2000
    
    while (year < 2021)
    {
        var mySubstring = String(String(year).suffix(2))
        var endYear:Int = Int(mySubstring)!
        endYear = endYear + 1
        mySubstring = String(endYear)
        if (endYear < 10)
        {
            mySubstring = "0\(endYear)"
        }
        var request = URLRequest(url: URL(string: "https://stats.nba.com/stats/draftcombineplayeranthro?LeagueID=00&SeasonYear=\(year)-\(mySubstring)")!,timeoutInterval: Double.infinity)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("stats", forHTTPHeaderField: "x-nba-stats-origin")
        request.addValue("true", forHTTPHeaderField: "x-nba-stats-token")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("stats.nba.com", forHTTPHeaderField: "Host")
        request.addValue("https://stats.nba.com/draft/combine-anthro/", forHTTPHeaderField: "Referer")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do
            {
                let stream = OutputStream(toFileAtPath: "./Draft_antro_\(year).csv", append: false)!
                let csv = try! CSVWriter(stream: stream)
                try! csv.write(row: [
                    "TEMP_PLAYER_ID",
                    "PLAYER_ID",
                    "FIRST_NAME",
                    "LAST_NAME",
                    "PLAYER_NAME",
                    "POSITION",
                    "HEIGHT_WO_SHOES",
                    "HEIGHT_WO_SHOES_FT_IN",
                    "HEIGHT_W_SHOES",
                    "HEIGHT_W_SHOES_FT_IN",
                    "WEIGHT",
                    "WINGSPAN",
                    "WINGSPAN_FT_IN",
                    "STANDING_REACH",
                    "STANDING_REACH_FT_IN",
                    "BODY_FAT_PCT",
                    "HAND_LENGTH",
                    "HAND_WIDTH"
                ])

                let draftSpotUp = try? JSONDecoder().decode(DraftRequest.self, from: data)

                for player in draftSpotUp!.resultSets[0].rowSet {
                    csv.beginNewRow()
                    switch player[0] {
                    case let .integer(id):
                        print("team player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[1] {
                    case let .integer(id):
                        print("player id is...  \(id)")
                        try! csv.write(field: String(id))
                    case .string(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[2] {
                    case let .string(name):
                        print("first name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[3] {
                    case let .string(name):
                        print("last name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[4] {
                    case let .string(name):
                        print("player name is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[5] {
                    case let .string(name):
                        print("position is...  \(name)")
                        try! csv.write(field: name)
                    case .integer(_):
                        break
                    case .double(_):
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[6] {
                    case let .double(double):
                        print("HEIGHT_WO_SHOES is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[7] {
                    case let .string(string):
                        print("HEIGHT_WO_SHOES_FT_IN is...  \(string)")
                        try! csv.write(field:string)
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[8] {
                    case let .double(double):
                        print("HEIGHT_W_SHOES is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[9] {
                    case let .string(string):
                        print("HEIGHT_W_SHOES_FT_IN is...  \(string)")
                        try! csv.write(field:string)
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[10] {
                    case let .string(string):
                        print("WEIGHT is...  \(string)")
                        try! csv.write(field:string)
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[11] {
                    case let .double(double):
                        print("WINGSPAN is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[12] {
                    case let .string(string):
                        print("WINGSPAN_FT_IN is...  \(string)")
                        try! csv.write(field:string)
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                        break
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[13] {
                    case let .double(double):
                        print("STANDING_REACH is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[14] {
                    case let .string(string):
                        print("STANDING_REACH_FT_IN is...  \(string)")
                        try! csv.write(field:string)
                    case let .double(double):
                        try! csv.write(field: String(double))
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[15] {
                    case let .double(double):
                        print("BODY_FAT_PCT is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[16] {
                    case let .double(double):
                        print("HAND_LENGTH is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                    switch player[17] {
                    case let .double(double):
                        print("HAND_WIDTH is...  \(double)")
                        try! csv.write(field: String(double))
                    case .string(_):
                        break
                    case let .integer(integer):
                        try! csv.write(field: String(integer))
                    case .null:
                        try! csv.write(field: "")
                        break
                    }
                }
                
                do {
                    sleep(1)
                }
                csv.stream.close()
                //     print(drafthistory!.resultSets[0].rowSet)
            }
            catch {
                print("CSV error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        year+=1
    }
    
}

//draftHistory()
//draftSpotUp()
//draftNonStationary()
//draftStrengthAgility()
//draftAntro()

for arg in CommandLine.arguments {
    if CommandLine.arguments.count > 3 {
        print("Usage: nba-stats draft TYPE")
        print("TYPE can be: history OR spotup OR nonstationary OR strengthagility OR antro, defaults to history")
    }
    else
    {
//    let draft = CommandLine.arguments[1]
        let stats = "draft"
        let type = CommandLine.arguments[2]
        if stats == "draft"{
            switch type {
                case "history":
                    draftHistory()
                case "spotup":
                    draftSpotUp()
                case "nonstationary":
                    draftNonStationary()
                case "strengthagility":
                    draftStrengthAgility()
                case "antro":
                    draftAntro()
                default:
                    draftHistory()
            }
        }
    }
}
