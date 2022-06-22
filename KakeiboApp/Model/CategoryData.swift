//
//  CategoryData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

struct CategoryData: Equatable {
    let id: String // swiftlint:disable:this identifier_name
    var displayOrder: Int
    var name: String
    var color: UIColor
}

extension CategoryData: Codable {
    enum CodingKeys: String, CodingKey {
        case id // swiftlint:disable:this identifier_name
        case displayOrder
        case name
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        name = try container.decode(String.self, forKey: .name)
        let colorData = try container.decode(Data.self, forKey: .color)
        guard let color =
                try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .color,
                        in: container,
                        debugDescription: "Invalid color"
                    )
                }
        self.color = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayOrder, forKey: .displayOrder)
        try container.encode(name, forKey: .name)
        let colorData = try NSKeyedArchiver.archivedData(
            withRootObject: color, requiringSecureCoding: UIColor.supportsSecureCoding
        )
        try container.encode(colorData, forKey: .color)
    }
}
