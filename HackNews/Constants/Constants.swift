//
//  Constants.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/03.
//

import Foundation

// Each Fetch's news loading number
let BATCH_SIZE = 25
let IMAGE_BUTTON_SIZE = 100.0

let TOP_STOREIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
let NEW_STOREIES_URL = "https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty"
let BEST_STOREIES_URL = "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"

func StoryContentURL(forID id: Int) -> String {
    return "https://hacker-news.firebaseio.com/v0/item/\(id).json?print=pretty"
}

struct Story: Codable {
    let id: Int
    let title: String
    let url: String?
    let time: TimeInterval
}
