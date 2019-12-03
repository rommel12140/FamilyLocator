//
//  FamilyOptionsViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 21/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MaterialComponents.MaterialBottomSheet

class FamilyOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let optionList:NSArray = ["Add Member", "Remove Members", "Leave Family"]
    let reference = Database.database().reference()
    var accountCodes = Array<String>()
    var familyCode:String!
    var userCode:String!
    var memberExist = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        getAccounts()

    }
    
    func getAccounts() {
        self.reference.child("users").observe( .value, with: { (snapshot) in
            self.accountCodes = Array<String>()
            for key in snapshot.children.allObjects{
                if let code = key as? DataSnapshot {
                    if let ac = code.key as? String{
                        self.accountCodes.append(ac)
                        print(self.accountCodes)
                        
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyOptionsTableViewCell
        
        cell.options.text = (optionList.object(at: indexPath.row) as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("add member")
            //1. Create the alert controller.
            let addMember = UIAlertController(title: "Add Member", message: "Account Code:", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            addMember.addTextField { (textField) in
                textField.text = ""
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            addMember.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak addMember] (_) in
                if addMember?.textFields![0].text == ""{
                    
                    let error = UIAlertController(title: "Add Member", message: "Please input an account code", preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak error] (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(error, animated: true, completion: nil)
                }
                else if let textField = addMember?.textFields![0].text{
                    let accountCode = "\(String(describing: textField))"
                    
                    for ac in self.accountCodes{
                        if ac == accountCode{
                            self.memberExist = true
                            print(self.memberExist)
                            break
                        }
                    }
                    
                    if self.memberExist == false{
                        let alert = UIAlertController(title: "Add Member", message: "Account does not exist", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak alert] (_) in
                            self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Add Member", message: "Invitation has been sent to the user", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
                           
                            print(accountCode)
                            print(self.familyCode)
                            self.reference.child("notifications").child(accountCode).child("invites").setValue([self.familyCode as! String: "pending"])
                        
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            addMember.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak addMember] (_) in
                self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
                
            }))
            
            // 4. Present the alert.
            self.present(addMember, animated: true, completion: nil)
        case 1:
            print("remove member")
            let alert = UIAlertController(title: "Remove Member", message: "Swipe left on any family member to remove that member from the family", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
            }))
            self.present(alert, animated: true, completion: nil)
        case 2:
            print("leave family")
            let alert = UIAlertController(title: "Leave Family", message: "Are you sure to leave the family?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
                
                self.reference.child("users").child(self.userCode!).child("families").updateChildValues([self.familyCode! : "deleted"])
                self.reference.child("family").child(self.familyCode!).child("members").updateChildValues([self.userCode! : "deleted"])
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
                self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
            }))
            
            self.present(alert, animated: true, completion: nil)
        default:
            print("default")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
