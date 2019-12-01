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
    var requestFamilyKeys = Array<String>()
    var requestFamilyNames = Array<String>()
    var notifications = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background
        UIGraphicsBeginImageContext(self.tableView.frame.size)
        UIImage(named: "background")?.draw(in: self.tableView.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.tableView.backgroundColor = UIColor(patternImage: image)
        print(self.user)
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
                        self.reference.child("family").child("\(inviteKey)").child("name").observe(.value, with: { (snapshot) in
                            if let name = snapshot.value{
                                print(self.inviteKeys)
                                self.inviteKeys.append(inviteKey)
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
            reference.child("users").child("\(user)").child("families").observe( .value, with: { (snapshot) in
                
                for familyCode in (snapshot.children.allObjects as! [DataSnapshot]){
                    if let code = familyCode.key as? String{
                        self.reference.child("family").child("\(code)").child("requests").observe( .value, with: { (snapshot) in
                            self.requests.removeAll()
                            self.requestKeys.removeAll()
                            self.requestFamilyKeys.removeAll()
                            self.requestFamilyNames.removeAll()
                            for request in (snapshot.children.allObjects as! [DataSnapshot]){
                                if let requestKey = request.key as? String{
                                    self.reference.child("users").child("\(requestKey)").observe(.value, with: { (snapshot) in
                                        if let fName = (snapshot.value as AnyObject) .value(forKey: "firstname") as? String, let lName = (snapshot.value as AnyObject) .value(forKey: "lastname") as? String{
                                            let fullname = ("\(fName) \(lName)")
                                            self.requestKeys.append(requestKey)
                                            self.requests.append(fullname)
                                            self.requestFamilyKeys.append(code)
                                            self.requestFamilyNames.append(familyCode.value as! String)
                                            self.tableView.reloadData()
                                        }
                                    }) { print($0) }
                                }
                            }
                        })
                    }
                }
            }) { print($0) }
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
            if invites.isEmpty{
                return 1
            }
            else{
                return invites.count
            }
        case 1:
            if requests.isEmpty{
                return 1
            }
            else{
                return requests.count
            }
        case 2:
            if notifications.isEmpty{
                return 1
            }
            else{
                return notifications.count
            }
        default:
            return 0
        }
        
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell: InvitationCell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath) as! InvitationCell
            if invites.isEmpty{
                cell.notificationLabel.text = "No invitations at the moment"
                cell.acceptButton.isHidden = true
                cell.rejectButton.isHidden = true
                cell.isUserInteractionEnabled = false
                
                return cell
            }
            else{
                cell.acceptButton.isHidden = false
                cell.rejectButton.isHidden = false
                cell.isUserInteractionEnabled = true
                
                reference.child("notifications").child(self.user as! String).child("invites").child(inviteKeys[indexPath.row]).observe( .value, with: { (snapshot) in
                    if let key = snapshot.value as? String{
                        if key == "accepted"{
                            cell.notificationLabel.textColor = UIColor.green
                            cell.acceptButton.isHidden = true
                            cell.rejectButton.isHidden = true
                        }
                        else if key == "rejected"{
                            cell.notificationLabel.textColor = UIColor.red
                            cell.acceptButton.isHidden = true
                            cell.rejectButton.isHidden = true
                        }
                        else{
                            cell.notificationLabel.textColor = UIColor.black
                            cell.acceptButton.isHidden = false
                            cell.rejectButton.isHidden = false
                            cell.acceptButton.tag = indexPath.row
                            cell.acceptButton.addTarget(self, action: #selector(self.acceptFamily(_:)), for: .touchUpInside)
                            
                            cell.rejectButton.tag = indexPath.row
                            cell.rejectButton.addTarget(self, action: #selector(self.declineFamily(_:)), for: .touchUpInside)
                        }
                    }
                    cell.contentView.alpha = 0.8;
                    cell.notificationLabel.text = "You have been added to \(self.invites[indexPath.row])"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    
                }) { print($0) }
                return cell
            }
        case 1:
            let cell: RequestCell = tableView.dequeueReusableCell(withIdentifier: "requests", for: indexPath) as! RequestCell
            
            if requests.isEmpty{
                cell.notificationLabel.text = "No requests at the moment"
                cell.acceptButton.isHidden = true
                cell.rejectButton.isHidden = true
                cell.isUserInteractionEnabled = false
                
                return cell
            }
            else{
                cell.acceptButton.isHidden = false
                cell.rejectButton.isHidden = false
                cell.isUserInteractionEnabled = true
            reference.child("family").child(requestFamilyKeys[indexPath.row]).child("requests").child(requestKeys[indexPath.row]).observe( .value, with: { (snapshot) in
                    if let key = snapshot.value as? String{
                        print(key)
                        if key == "accepted"{
                            cell.notificationLabel.textColor = UIColor.green
                            cell.acceptButton.isHidden = true
                            cell.rejectButton.isHidden = true
                        }
                        else if key == "rejected"{
                            cell.notificationLabel.textColor = UIColor.red
                            cell.acceptButton.isHidden = true
                            cell.rejectButton.isHidden = true
                        }
                        else{
                            cell.notificationLabel.textColor = UIColor.black
                            cell.acceptButton.isHidden = false
                            cell.rejectButton.isHidden = false
                            cell.acceptButton.tag = indexPath.row
                            cell.acceptButton.addTarget(self, action: #selector(self.acceptRequest(_:)), for: .touchUpInside)
                            
                            cell.rejectButton.tag = indexPath.row
                            cell.rejectButton.addTarget(self, action: #selector(self.declineRequest(_:)), for: .touchUpInside)
                        }
                    }
                    cell.contentView.alpha = 0.8;
                    cell.notificationLabel.text = "\(self.requests[indexPath.row]) wants to join to \(self.requestFamilyNames[indexPath.row])"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    
                }) { print($0) }
            
                return cell
            }
        case 2:
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationCell
            
            if notifications.isEmpty{
                cell.notificationLabel.text = "No notifications at the moment"
                
                return cell
            }
            else{
                cell.layoutMargins.bottom = 5
                cell.contentView.alpha = 0.8;
                cell.notificationLabel.text = notifications[indexPath.row]
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
            
        default:
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationCell
            print("default")
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    //invites
    
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
    //----------------
    
    //requests
    
    @objc func acceptRequest(_ sender: UIButton) {
        let alert = UIAlertController(title: "Accept request?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.reference.child("family").child(self.requestFamilyKeys[sender.tag]).child("requests").updateChildValues([self.requestKeys[sender.tag] : "accepted"])
            
            let message = "Request of \(self.requests[sender.tag]) to join \(self.requestFamilyNames[sender.tag]) is accepted"
           
            self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.requestKeys[sender.tag] : message])
           
            //add to members
            self.reference.child("users").child(self.requestKeys[sender.tag]).child("families").updateChildValues([self.requestFamilyKeys[sender.tag] : "joined"])
            self.reference.child("family").child(self.requestFamilyKeys[sender.tag]).child("members").childByAutoId().setValue(self.requestKeys[sender.tag])
            
            self.tableView.reloadData()

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
        
        let message = "Request of \(self.requests[sender.tag]) to join \(self.requestFamilyKeys[sender.tag]) is rejected"
       
        self.reference.child("notifications").child(self.user as! String).child("notifications").updateChildValues([self.requestFamilyNames[sender.tag] : message])
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    //-----------------
    
}

