//
//  MenuOptionsTableViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 22/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MenuOptionsTableViewController: UITableViewController {

    let optionList:NSArray = ["CREATE A FAMILY", "JOIN A FAMILY", "NOTIFICATIONS", "LOGOUT"]
    let reference = Database.database().reference()
    var user:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuOptionsTableViewCell
        
        cell.options.text = (optionList.object(at: indexPath.row) as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
        
        switch indexPath.row {
        case 0:
            print("create")
            //1. Create the alert controller.
            let createFamily = UIAlertController(title: "Create Family", message: "Family Name:", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            createFamily.addTextField { (textField) in
                textField.text = ""
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            createFamily.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak createFamily] (_) in
                if let textField = createFamily?.textFields![0].text{
                    var count = 0
                    let code = self.createRandomHex()
                    let familyCode = "\(String(describing: textField))-\(code)"
                    print(familyCode)
                    let ref = self.reference.child("users").child(self.user).child("families")
                    
                    print("Starting observing");
                    ref.observe(.value, with: { (snapshot: DataSnapshot!) in
                        print("Got snapshot");
                        print(snapshot.childrenCount)
                        count = Int(snapshot.childrenCount)
                        print("count inside observe: \(count)")
                    })
                    print("count outside observe: \(count)")
//                    self.reference.child("family").child(familyCode).child("members").setValue(["0" : self.user])
//                    self.reference.child("family").child(familyCode).updateChildValues(["name" : textField])
//                    self.reference.child("users").child(self.user).child("families").updateChildValues([String(count) : familyCode])
                }
                
                let alert = UIAlertController(title: "Create Family", message: "Successfully created the family", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.dismiss(animated: true, completion: nil) // Force unwrapping because we know it exists.
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }))
            
            // 4. Present the alert.
            self.present(createFamily, animated: true, completion: nil)
        case 1:
            print("join")
        case 2:
            print("notification")
        case 3:
            let reference = Database.database().reference()
            
            reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                //present view controller while passing userCode from database
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
                let navController = UINavigationController()
                if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                    reference.child("users").child("\(userCode)").updateChildValues(["isOnline" : "false"])
                    navController.dismiss(animated: true, completion: nil)
                    self.present(viewController, animated: true, completion: nil)
                }
            })
        default:
            print("default")
        
        }
    }
        
    func createRandomHex() -> String{
        return String(format: "%04X", Int(arc4random() % 655), Int(arc4random() % 655))
    }


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
