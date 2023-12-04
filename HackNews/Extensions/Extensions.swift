//
//  Extensions.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/03.
//

import Foundation

extension TimeInterval {
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
