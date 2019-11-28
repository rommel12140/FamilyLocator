//
//  NotificationTableViewController.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 22/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NotificationTableViewController: UITableViewController {
    

    let reference = Database.database().reference()
    var user: String!
    var invites = Array<String>()
    var inviteKeys = Array<String>()
    var requests = Array<String>()
    var requestKeys = Array<String>()
    var notifications = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background
        UIGraphicsBeginImageContext(self.tableView.frame.size)
        UIImage(named: "background")?.draw(in: self.tableView.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.tableView.backgroundColor = UIColor(patternImage: image)
        getNotifs()
    }
    
    @IBAction func goBack(_ sender: Any) {
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    
    func getNotifs() {
        if let user = user{
            reference.child("notifications").child("\(user)" ).child("invites").observe( .value, with: { (snapshot) in
                self.inviteKeys.removeAll()
                self.invites.removeAll()
                for invite in (snapshot.children.allObjects as! [DataSnapshot]){
                    if let inviteKey = invite.key as? String{
                        self.inviteKeys.append(inviteKey)
                        self.reference.child("family").child("\(inviteKey)").child("name").observe(.value, with: { (snapshot) in
                            if let name = snapshot.value{
                                self.invites.append(name as! String)
                                self.tableView.reloadData()
                            }
                        }) { print($0) }
                    }
                    
                }
            }) { print($0) }
            reference.child("notifications").child("\(user)" ).child("notifications").observe( .value, with: { (snapshot) in
                self.notifications.removeAll()
                for notif in (snapshot.children.allObjects as! [DataSnapshot]){
                    if let name = notif.value{
                        self.notifications.append(name as! String)
                        self.tableView.reloadData()
                    }
                }
            }) { print($0) }
            for key in inviteKeys{
                print("invitekey")
                print(key)
                reference.child("family").child("\(key)").child("requests").observe( .value, with: { (snapshot) in
                    self.requests.removeAll()
                    self.requestKeys.removeAll()
                    for requests in (snapshot.children.allObjects as! [DataSnapshot]){
                        if let requestKeys = requests.key as? String{
                            self.requestKeys.append(requestKeys)
                            self.reference.child("users").child("\(requestKeys)").observe(.value, with: { (snapshot) in
                                if let fName = (snapshot.value as AnyObject) .value(forKey: "firstname") as? String, let lName = (snapshot.value as AnyObject) .value(forKey: "lastname") as? String{
                                    let fullname = ("\(fName) \(lName)")
                                    print(fullname)
                                    self.requests.append(fullname)
                                }
                            }) { print($0) }
                        }
                        
                    }
                }) { print($0) }
            }
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Invites"
        case 1:
            return "Requests"
        case 2:
            return "Notifications"
        default:
            return nil
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return invites.count
        case 1:
            return requests.count
        case 2:
            return notifications.count
        default:
            return 0
        }
        
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: InvitationCell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath) as! InvitationCell
            cell.layer.cornerRadius = cell.layer.frame.height/4
            
            reference.child("notifications").child(self.user as! String).child("invites").child(inviteKeys[indexPath.row]).observe( .value, with: { (snapshot) in
                print(snapshot.key)
                if let key = snapshot.value{
                    print(key)
                    if key as! String == "accepted"{
                        cell.backgroundColor = UIColor.green
                        cell.acceptButton.isHidden = true
                        cell.rejectButton.isHidden = true
                    }
                    else if key as! String == "rejected"{
                        cell.backgroundColor = UIColor.red
                        cell.acceptButton.isHidden = true
                        cell.rejectButton.isHidden = true
                    }
                    else{
                        cell.backgroundColor = UIColor.white
                        cell.acceptButton.isHidden = false
                        cell.rejectButton.isHidden = false
                        cell.acceptButton.tag = indexPath.row
                        cell.acceptButton.addTarget(self, action: #selector(self.acceptFamily(_:)), for: .touchUpInside)
                        
                        cell.rejectButton.tag = indexPath.row
                        cell.rejectButton.addTarget(self, action: #selector(self.declineFamily(_:)), for: .touchUpInside)
                    }
                }
            }) { print($0) }
            
            cell.contentView.alpha = 0.8;
            cell.notificationLabel.text = "You have been added to \(invites[indexPath.row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case 1:
            let cell: RequestCell = tableView.dequeueReusableCell(withIdentifier: "request", for: indexPath) as! RequestCell
            cell.layer.cornerRadius = cell.layer.frame.height/4
            
            reference.child("family").child(inviteKeys[indexPath.row]).child("requests").observe( .value, with: { (snapshot) in
                print("inside request")
                print(snapshot.key)
                if let key = snapshot.value{
                    print(key)
                    if key as! String == "accepted"{
                        cell.backgroundColor = UIColor.green
                        cell.acceptButton.isHidden = true
                        cell.rejectButton.isHidden = true
                    }
                    else if key as! String == "rejected"{
                        cell.backgroundColor = UIColor.red
                        cell.acceptButton.isHidden = true
                        cell.rejectButton.isHidden = true
                    }
                    else{
                        cell.backgroundColor = UIColor.white
                        cell.acceptButton.isHidden = false
                        cell.rejectButton.isHidden = false
                        cell.acceptButton.tag = indexPath.row
                        cell.acceptButton.addTarget(self, action: #selector(self.acceptRequest(_:)), for: .touchUpInside)
                        
                        cell.rejectButton.tag = indexPath.row
                        cell.rejectButton.addTarget(self, action: #selector(self.declineRequest(_:)), for: .touchUpInside)
                    }
                }
            }) { print($0) }
            
            cell.contentView.alpha = 0.8;
            cell.notificationLabel.text = "You have been added to \(invites[indexPath.row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case 2:
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationCell
            cell.layer.cornerRadius = cell.layer.frame.height/4
            cell.layoutMargins.bottom = 5
            cell.contentView.alpha = 0.8;
            cell.notificationLabel.text = notifications[indexPath.row]
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        default:
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationCell
            print("default")
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func acceptFamily(_ sender: UIButton) {
        let alert = UIAlertController(title: "Join Family?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.reference.child("notifications").child("\(self.user as! String)").child("invites").updateChildValues([self.inviteKeys[sender.tag] : "accepted"])
            
            let message = "Welcome to \(self.invites[sender.tag])"
            self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.inviteKeys[sender.tag] : message])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func declineFamily(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reject Family?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.reference.child("notifications").child("\(self.user as! String)").child("invites").updateChildValues([self.inviteKeys[sender.tag] : "rejected"])
            
            let message = "You have been removed from \(self.invites[sender.tag])"
            self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.inviteKeys[sender.tag] : message])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func acceptRequest(_ sender: UIButton) {
        let alert = UIAlertController(title: "Accept request?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.reference.child("family").child(self.inviteKeys[sender.tag]).child("requests").updateChildValues([self.requestKeys[sender.tag] : "accepted"])
            
            let message = "Request of \(self.requests[sender.tag]) to join \(self.invites[sender.tag]) is accepted"
            self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.inviteKeys[sender.tag] : message])
            self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.requestKeys[sender.tag] : message])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func declineRequest(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reject request?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in self.reference.child("family").child(self.inviteKeys[sender.tag]).child("requests").updateChildValues([self.requestKeys[sender.tag] : "rejected"])
        
        let message = "Request of \(self.requests[sender.tag]) to join \(self.invites[sender.tag]) is rejected"
        self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.inviteKeys[sender.tag] : message])
        self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.requestKeys[sender.tag] : message])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
}

