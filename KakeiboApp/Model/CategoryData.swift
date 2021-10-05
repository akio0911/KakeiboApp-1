//
//  CategoryData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import Foundation
import UIKit

struct CategoryData {
    let id: String
    var name: String
    var color: UIColor
}

extension CategoryData: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let colorData = try container.decode(Data.self, forKey: .color)
        let rgba = try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)!.rgba
        color = UIColor(red: rgba.red / 255, green: rgba.green / 255, blue: rgba.blue / 255, alpha: rgba.alpha)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let colorData = try! NSKeyedArchiver.archivedData(
            withRootObject: color, requiringSecureCoding: UIColor.supportsSecureCoding)
        try container.encode(colorData, forKey: .color)
    }
}