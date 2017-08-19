//
//  AddPostTableViewController.swift
//  Nutstagram
//
//  Created by smigus on 8/12/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit

protocol AddPostControllerDelegate {
    func addPostController(_ addPostController: AddPostTableViewController, didAdd image: UIImage, by user: User)
}

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    enum Section: Int {
        case userInformation, post
        
        static var count = 2
    }
    
    var delegate: AddPostControllerDelegate?

    private var postImage: UIImage?
    
    private var nameTextField: UITextField?
    private var emojiTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = postImage else { return }
        
        guard let name = nameTextField?.text else { return }
        guard let emoji = emojiTextField?.text else { return }
        
        if name != "" && emoji != "" {
            delegate?.addPostController(self, didAdd: image, by: User(name: name, emojiProfilePic: emoji))
            print("Upload done")
        }
        
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { fatalError() }
        
        switch section {
        case .userInformation: return 2
        case .post: return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addPostCell", for: indexPath)

        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        
        switch section {
        case .userInformation:
            configureUserInformationCell(cell, forRow: indexPath.row)
        case .post:
            (indexPath.row == 0) ? configureChooseImageCell(cell) : configureImageCell(cell)
        }

        return cell
    }
    
    private func configureUserInformationCell(_ cell: UITableViewCell, forRow row: Int) {
        let textField = UITextField()
        textField.frame = cell.contentView.frame.insetBy(dx: cell.indentationWidth, dy: 0)
        
        if row == 0 {
            nameTextField = textField
            textField.placeholder = "User Name"
        } else {
            emojiTextField = textField
            textField.placeholder = "Emoji Profile Pic"
        }
        
        cell.contentView.addSubview(textField)
    }
    
    private func configureChooseImageCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Choose an image"
    }
    
    private func configureImageCell(_ cell: UITableViewCell) {
        if let postImage = postImage {
            cell.textLabel?.text = nil
            cell.imageView?.image = postImage
            return
        }
        
        cell.textLabel?.text = "Image not set"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType == "public.image" {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            postImage = image
        }
        
        dismiss(animated: true, completion: nil)
        tableView.reloadSections([1], with: .automatic)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
