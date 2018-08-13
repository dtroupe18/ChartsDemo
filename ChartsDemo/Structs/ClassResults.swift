//
//  ClassResult.swift
//  ChartsDemo
//
//  Created by Dave Troupe on 8/12/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct ClassResults: Codable {
    let uid: Int
    let classDate: String
    let classType: ClassType
    let totalPower: Int
    
    enum CodingKeys: String, CodingKey {
        case uid
        case classDate = "class_date"
        case classType = "class_type"
        case totalPower = "total_power"
    }
}

enum ClassType: String, Codable {
    case beats = "Beats"
    case method = "Method"
    case power = "Power"
    case tempo = "Tempo"
}
