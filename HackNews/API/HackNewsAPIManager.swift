//
//  HackNewsAPIManager.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/01.
//

import Foundation

class HackNewsAPIManager {

    var storyIDs = [Int]()
    var downloadedStories = [Story]()
    var lastDownloadedStoryIndex = 0

    enum StoryType {
        case top
        case new
        case best
    }

    var currentStoryType: StoryType = .top

    
    func downloadStoriesByType(completion: @escaping ([Story]) -> Void) {

        let urlString: String
        switch currentStoryType {
        case .top:
            urlString = TOP_STOREIES_URL
        case .new:
            urlString = NEW_STOREIES_URL
        case .best:
            urlString = BEST_STOREIES_URL
        }

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, var ids = try? JSONDecoder().decode([Int].self, from: data) {
                //descending sort, in case it's wrong on server side
                ids.sort(by: >)
                self?.storyIDs = ids
                //print("whole ids is ")
                //ids.forEach { print($0) }
                self?.downloadStoriesBatch(completion: completion)
            } else if let error = error {
                print("Network error: \(error)")
                completion([])
            }
        }.resume()
    }


    func downloadStoriesBatch(completion: @escaping ([Story]) -> Void) {
        guard lastDownloadedStoryIndex < storyIDs.count else {
            completion([])
            print("this is the last of stories")
            return
        }
        let endIndex = min(lastDownloadedStoryIndex + BATCH_SIZE, storyIDs.count)
        let batch = Array(storyIDs[lastDownloadedStoryIndex..<endIndex])
        lastDownloadedStoryIndex = endIndex
        var batchStories = [Story]()
        let group = DispatchGroup()

        for id in batch {
            group.enter()
            let urlString = StoryContentURL(forID: id)
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                if let data = data, let story = try? JSONDecoder().decode(Story.self, from: data) {
                    batchStories.append(story)
                }
            }.resume()
        }

        group.notify(queue: .main) {
            self.lastDownloadedStoryIndex += batch.count
            self.downloadedStories.append(contentsOf: batchStories.sorted { $0.id > $1.id })
            completion(self.downloadedStories)
        }
    }
}

