//
//  NetworkSessionProtocol.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/04.
//

import Foundation

protocol NetworkSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

protocol NewsAPIManagerProtocol {
    var currentStoryType: HackNewsAPIManager.StoryType { get set }
    // other required methods
}

extension URLSession: NetworkSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url, completionHandler: completionHandler)
    }
}
