//
//  NewsTableViewControllerTests.swift
//  HackNewsTests
//
//  Created by Chan Gu on 2023/12/04.
//

import XCTest
@testable import HackNews

class NewsTableViewControllerTests: XCTestCase {

    var viewController: NewsTableViewController!
    var mockAPIManager: MockHackNewsAPIManager!

    override func setUp() {
        super.setUp()
        viewController = NewsTableViewController()
        mockAPIManager = MockHackNewsAPIManager()
        viewController.hackNewsAPIManager = mockAPIManager
        viewController.loadViewIfNeeded()
    }

    func testSegmentChanged() {
        viewController.segmentControl.selectedSegmentIndex = 1 //new
        viewController.segmentChanged(viewController.segmentControl)

        // Assert that the current story type is set to .new
        XCTAssertEqual(mockAPIManager.currentStoryType, .new, "currentStoryType should be .new after selecting the 'New' segment")

        // Assert that downloadStoriesByType is called
        XCTAssertTrue(mockAPIManager.downloadStoriesByTypeCalled, "downloadStoriesByType should be called when a segment is changed")
    }

    override func tearDown() {
        viewController = nil
        mockAPIManager = nil
        super.tearDown()
    }
}


class MockHackNewsAPIManager: HackNewsAPIManager {
    var downloadStoriesByTypeCalled = false

    override func downloadStoriesByType(completion: @escaping ([Story]) -> Void) {
        downloadStoriesByTypeCalled = true
        // Optionally, call completion with mock data if needed
    }
}
