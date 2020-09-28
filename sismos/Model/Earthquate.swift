//
//  Earthquate.swift
//  sismos
//
//  Created by Familia Juarez Martinez on 9/25/20.
//

import Foundation

//struct Response:Decodable {
//    var metadata: Features
//}

struct Response: Decodable {
    var features:[Properties]
}

struct Properties: Decodable {
    var type: String
    var properties: Details
}

struct Details: Decodable {
        var mag: Float?
        var alert: String?
        var place: String?
        var time: Int64?
        var detail: String?
//        var extra: Geometry
}

