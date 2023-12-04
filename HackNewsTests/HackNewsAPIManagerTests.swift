//
//  HackNewsAPIManagerTests.swift
//  HackNewsTests
//
//  Created by Chan Gu on 2023/12/04.
//

import XCTest
@testable import HackNews

final class HackNewsAPIManagerTests: XCTestCase {


    var manager: HackNewsAPIManager!
    var mockSession: MockNetworkSession!

    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        manager = HackNewsAPIManager(networkSession: mockSession)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testDownloadStoriesBatch() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "mockStories", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url),
              let storiesArray = try? JSONDecoder().decode([Story].self, from: jsonData) else {
            XCTFail("Failed to load or decode MockStories.json")
            return
        }

        // Map each story to its URL and set the mock response
        for story in storiesArray {
            guard let storyData = try? JSONEncoder().encode(story),
                  let storyURL = URL(string: StoryContentURL(forID: story.id)) else {
                continue
            }
            mockSession.setMockResponse(data: storyData, error: nil, forURL: storyURL)
        }

        // Initialize `lastDownloadedStoryIndex` and `storyIDs`
        manager.lastDownloadedStoryIndex = 0
        manager.storyIDs = storiesArray.map { $0.id }

        let expectation = self.expectation(description: "Download stories batch")

        manager.downloadStoriesBatch { stories in
            XCTAssertEqual(stories.count, storiesArray.count)
            for story in stories {
                guard let expectedStory = storiesArray.first(where: { $0.id == story.id }) else {
                    XCTFail("Story with ID \(story.id) was not expected.")
                    continue
                }
                XCTAssertEqual(story.title, expectedStory.title, "Story title does not match for ID \(story.id).")
                XCTAssertEqual(story.url, expectedStory.url, "Story URL does not match for ID \(story.id).")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDownloadStoriesBatchWithError() {
        // Create a common error to use for mock responses
        let error = NSError(domain: "TestError", code: 0, userInfo: nil)

        for id in [1, 2] { // Example story IDs
            if let url = URL(string: StoryContentURL(forID: id)) {
                mockSession.setMockResponse(data: nil, error: error, forURL: url)
            }
        }

        // Initialize `lastDownloadedStoryIndex` and `storyIDs`
        manager.lastDownloadedStoryIndex = 0
        manager.storyIDs = [1, 2] // Example story IDs

        let expectation = self.expectation(description: "Download stories batch with error")

        manager.downloadStoriesBatch { stories in
            XCTAssertEqual(stories.count, 0, "No stories should be returned in case of an error.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}


class MockURLSessionDataTask: URLSessionDataTask {
    private let completionHandler: (Data?, URLResponse?, Error?) -> Void
    private let mockData: Data?
    private let mockError: Error?

    init(data: Data?, error: Error?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.mockData = data
        self.mockError = error
        self.completionHandler = completionHandler
    }

    override func resume() {
        completionHandler(mockData, nil, mockError)
    }
}

class MockNetworkSession: NetworkSession {
    // Dictionary to hold mock responses for specific URLs
    private var urlResponses = [URL: (data: Data?, error: Error?)]()

    // Method to set mock response for a specific URL
    func setMockResponse(data: Data?, error: Error?, forURL url: URL) {
        urlResponses[url] = (data, error)
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // Fetch the response for the given URL, if it exists
        let response = urlResponses[url]

        // Return a MockURLSessionDataTask with the response specific to the URL
        return MockURLSessionDataTask(data: response?.data, error: response?.error, completionHandler: completionHandler)
    }
}
