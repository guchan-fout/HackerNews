//
//  NewsTableViewController.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/01.
//

import UIKit
import SafariServices

class NewsTableViewController: UITableViewController {

    var stories = [Story]()
    let hackNewsAPIManager = HackNewsAPIManager()
    var activityIndicatorView: UIActivityIndicatorView!

    var isLoading = false
    var isLastStory = true

    var segmentControl: UISegmentedControl!


    override func viewDidLoad() {
        super.viewDidLoad()

        // add Segment for news switch, top/new/best
        self.setSegmentControl()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // This is an off-white color, like real newspaper
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)

        //start loading view because first loading take time
        startIndicatorView()

        hackNewsAPIManager.downloadStoriesByType { [weak self] downloadedStories in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                self?.stories = downloadedStories
                self?.tableView.reloadData()
            }
        }
    }

    private func setSegmentControl () {
        segmentControl = UISegmentedControl(items: ["Top", "New", "Best"])
        segmentControl.selectedSegmentIndex = 0 // Default selection
        segmentControl.backgroundColor = .systemBackground
        segmentControl.selectedSegmentTintColor = .systemBlue

        navigationItem.titleView = segmentControl
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            //Top selected
        case 0:
            hackNewsAPIManager.currentStoryType = .top
        case 1:
            hackNewsAPIManager.currentStoryType = .new
        case 2:
            hackNewsAPIManager.currentStoryType = .best
        default:
            break
        }

        // Reset and fetch stories based on the new selection
        hackNewsAPIManager.storyIDs = []
        hackNewsAPIManager.downloadedStories = []
        hackNewsAPIManager.lastDownloadedStoryIndex = 0
        hackNewsAPIManager.downloadStoriesByType { [weak self] newStories in
            DispatchQueue.main.async {
                self?.stories = newStories
                self?.tableView.reloadData()
            }
        }
    }

    private func startIndicatorView() {
        // indicator at first loading of News
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        tableView.backgroundView = activityIndicatorView

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        activityIndicatorView.startAnimating()
    }

    @objc func backButtonTapped() {
        // Dismiss the current view controller
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print (stories.count)
        return stories.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let story = stories[indexPath.row]
        cell.textLabel?.text = story.title
        cell.detailTextLabel?.text = "Posted on: \(story.time.formattedDate)"

        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // check if list is at last, then update
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)

        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if lastVisibleIndexPath >= lastIndexPath && !isLoading && isLastStory {
                isLoading = true
                loadMoreStories()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let story = stories[indexPath.row]

        guard let urlString = story.url, let url = URL(string: urlString) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        let actionSheet = UIAlertController(title: "Open Link", message: "Choose how to open this link", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Open Internally", style: .default, handler: { _ in
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
            UIApplication.shared.open(url)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func loadMoreStories() {
        print("start to load new stories")
        hackNewsAPIManager.downloadStoriesBatch { [weak self] newStories in
            DispatchQueue.main.async {
                let uniqueNewStories = newStories.filter { newStory in
                    !(self?.stories.contains { $0.id == newStory.id } ?? false)
                }

                if uniqueNewStories.isEmpty {
                    self?.isLastStory = false
                } else {
                    self?.stories.append(contentsOf: uniqueNewStories)
                    self?.tableView.reloadData()
                }
                self?.isLoading = false
            }
        }
    }
}
