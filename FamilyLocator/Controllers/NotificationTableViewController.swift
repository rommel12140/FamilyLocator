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
                        if invite.value as? String == "pending"{
                            self.reference.child("family").child("\(inviteKey)").child("name").observe(.value, with: { (snapshot) in
                                if let name = snapshot.value{
                                    self.inviteKeys.append(inviteKey)
                                    self.invites.append(name as! String)
                                    self.tableView.reloadData()
                                }
                            }) { print($0) }
                        }
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
                        self.reference.child("family").child("\(code)").observe( .value, with: { (snapshot) in
                            self.requestFamilyNames.removeAll()
                            for request in (snapshot.childSnapshot(forPath: "requests").children.allObjects as! [DataSnapshot]){
                                self.requests.removeAll()
                                self.requestKeys.removeAll()
                                self.requestFamilyKeys.removeAll()
                                if request.value as? String == "pending"{
                                    if let name = snapshot.childSnapshot(forPath: "name").value{
                                        if let requestKey = request.key as? String{
                                            self.reference.child("users").child("\(requestKey)").observe( .value, with: { (snapshot) in
                                                if let fName = (snapshot.value as AnyObject) .value(forKey: "firstname") as? String, let lName = (snapshot.value as AnyObject) .value(forKey: "lastname") as? String{
                                                    let fullname = ("\(fName) \(lName)")
                                                    self.requestKeys.append(requestKey)
                                                    self.requests.append(fullname)
                                                    self.requestFamilyKeys.append(code)
                                                    self.requestFamilyNames.append(name as! String)
                                                    self.tableView.reloadData()
                                                }
                                                self.tableView.reloadData()
                                            }) { print($0) }
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                self.tableView.reloadData()
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
                        cell.notificationLabel.textColor = UIColor.black
                        cell.acceptButton.isHidden = false
                        cell.rejectButton.isHidden = false
                        cell.acceptButton.tag = indexPath.row
                        cell.acceptButton.addTarget(self, action: #selector(self.acceptFamily(_:)), for: .touchUpInside)
                        
                        cell.rejectButton.tag = indexPath.row
                        cell.rejectButton.addTarget(self, action: #selector(self.declineFamily(_:)), for: .touchUpInside)
                        
                        cell.notificationLabel.text = "You have been added to \(self.invites[indexPath.row])"
                    }
                    cell.contentView.alpha = 0.8;
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
                        cell.notificationLabel.textColor = UIColor.black
                        cell.acceptButton.isHidden = false
                        cell.rejectButton.isHidden = false
                        cell.acceptButton.tag = indexPath.row
                        cell.acceptButton.addTarget(self, action: #selector(self.acceptRequest(_:)), for: .touchUpInside)
                        
                        cell.rejectButton.tag = indexPath.row
                        cell.rejectButton.addTarget(self, action: #selector(self.declineRequest(_:)), for: .touchUpInside)
                        cell.notificationLabel.text = "\(self.requests[indexPath.row]) wants to join to \(self.requestFamilyNames[indexPath.row])"
                    }
                    cell.contentView.alpha = 0.8;
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
            
            let refCount = self.reference.child("users").child(self.user!).child("families")
            
            refCount.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                let count = Int(snapshot.childrenCount)
                print(count)
                if count < 3{
                    self.reference.child("notifications").child("\(self.user!)").child("invites").updateChildValues([self.inviteKeys[sender.tag] : "accepted"])
                    
                    self.reference.child("family").child("\(self.inviteKeys[sender.tag])").child("members").updateChildValues([self.user! : "joined"])
                    
                    self.reference.child("users").child("\(self.user!)").child("families").updateChildValues([self.inviteKeys[sender.tag] : "joined"])
                    
                    
                    
                    let message = "Welcome to \(self.invites[sender.tag])"
                    self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
                }
                else{
                    let alert = UIAlertController(title: "Join Family", message: "You have reached the maximum limit of families you can join", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
           
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
            
            self.reference.child("notifications").child("\(self.user!)").child("invites").updateChildValues([self.inviteKeys[sender.tag] : "rejected"])
            
            let message = "You have declined to join \(self.invites[sender.tag])"
            self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
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
//            self.reference.child("family").child(self.requestFamilyKeys[sender.tag]).child("requests").child(self.requestKeys[sender.tag]).removeValue()
            
            
            let message = "Request of \(self.requests[sender.tag]) to join \(self.requestFamilyNames[sender.tag]) has been accepted"
           
            self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
            
            let message2 = "Your request to join \(self.requestFamilyNames[sender.tag]) has been accepted"
            
            self.reference.child("notifications").child(self.requestKeys[sender.tag]).child("notifications").childByAutoId().setValue(message2)
           
            //add to members
            self.reference.child("users").child(self.requestKeys[sender.tag]).child("families").updateChildValues([self.requestFamilyKeys[sender.tag] : "joined"])
            self.reference.child("family").child(self.requestFamilyKeys[sender.tag]).child("members").updateChildValues([self.requestKeys[sender.tag] : "joined"])

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func declineRequest(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reject request?",
                                      message: "",
                                      preferredStyle: .alert)
        
        //alert with error
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
        self.reference.child("family").child(self.inviteKeys[sender.tag]).child("requests").updateChildValues([self.requestKeys[sender.tag] : "rejected"])
//        self.reference.child("family").child(self.requestFamilyKeys[sender.tag]).child("requests").child(self.requestKeys[sender.tag]).removeValue()
        
        let message = "Request of \(self.requests[sender.tag]) to join \(self.requestFamilyKeys[sender.tag]) has been rejected"
       
        self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
        
        let message2 = "Your request to join \(self.requestFamilyNames[sender.tag]) has been rejected"
        
        self.reference.child("notifications").child(self.requestKeys[sender.tag]).child("notifications").childByAutoId().setValue(message2)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    //-----------------
    
}
