//
//  NutstagramCommentsTableViewController.swift
//  Nutstagram
//
//  Created by Jared Franzone on 7/30/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

class NutstagramCommentsTableViewController: UIViewController {
    
    // MARK: IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    public var comments: [String]?
    
    // MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    }
}

// MARK: - UITableViewDelegate extension

extension NutstagramCommentsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UITableViewDataSource extension

extension NutstagramCommentsTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfComments = comments?.count else {
            return 0
        }
        return numberOfComments
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comments = self.comments else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\"\(comments[indexPath.row])\""
        return cell
    }
}
