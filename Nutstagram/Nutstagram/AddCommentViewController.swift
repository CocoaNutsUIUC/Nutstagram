//
//  AddCommentViewController.swift
//  Nutstagram
//
//  Created by smigus on 8/18/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

protocol AddCommentViewControllerDelegate {
    func addComment(_ comment: String, postId: Int, row: Int)
}

class AddCommentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.becomeFirstResponder()
        automaticallyAdjustsScrollViewInsets = false
    }

    @IBOutlet weak var textView: UITextView!
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.addComment(textView.text, postId: postId, row: row)
        navigationController?.popViewController(animated: true)
    }
        
    var delegate: AddCommentViewControllerDelegate?
    var postId: Int!
    var row: Int!

}
