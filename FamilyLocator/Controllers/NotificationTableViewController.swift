//
//  NotificationTableViewController.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 22/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController, NotificationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background
        UIGraphicsBeginImageContext(self.tableView.frame.size)
        UIImage(named: "LoginBackground")?.draw(in: self.tableView.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.tableView.backgroundColor = UIColor(patternImage: image)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Invites"
        }
        else{
            return "Notifications"
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell: InvitationCell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath) as! InvitationCell
            cell.delegate = self
            cell.layer.cornerRadius = cell.layer.frame.height/4
            cell.contentView.alpha = 0.8;
            cell.notificationLabel.text = "\("hello") wants you to join their family."
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else{
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationCell
            cell.layer.cornerRadius = cell.layer.frame.height/4
            cell.contentView.alpha = 0.8;
            cell.notificationLabel.text = "Rommel left the family."
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func acceptFamily() {
        let alert = UIAlertController(title: "Join Family?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func declineFamily() {
        let alert = UIAlertController(title: "Reject Family?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

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
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

