//
//  UserSelectionTableViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 20/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import MXParallaxHeader
import MaterialComponents.MaterialBottomSheet
import FirebaseDatabase
import FirebaseStorage

struct Member{
    var key: String!
    var name: String!
    var firstName: String!
    var status: String!
    var image: UIImage!
}

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: String!
    var selectedUsers = NSMutableArray()
    var selectedUsersFirstName = NSMutableArray()
    var selectedUsersImages = NSMutableArray()
    var familyCodes = Array<String>()
    var familyNames = Array<String>()
    var families = Array<Array<Member>>()
    var firstName: String!
    var lastName: String!
    var selectedCount = 0
    let reference = Database.database().reference()
    let storageRef = Storage.storage()
    var familyRef = Array<DatabaseReference>()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var accountCode: UILabel!
    @IBOutlet weak var locateButton: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFamilyCode()
        setup()
        setupHeader()
        displayUserData()
        navBarModifications()
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        setupHeader()
        selectedCount = 0
        selectedUsers.removeAllObjects()
        selectedUsersFirstName.removeAllObjects()
        selectedUsersImages.removeAllObjects()
        locateButton.isEnabled = false
        locateButton.alpha = 0.7
        tableView.reloadData()
        tableView.parallaxHeader.minimumHeight = view.safeAreaInsets.top
    }
    
    func setup() {
        tableView.estimatedRowHeight = 100
        
        headerView.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
        // Parallax Header
        tableView.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        tableView.parallaxHeader.height = 300
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.delegate = self
        
        //header for table view
        // The below line is to eliminate the empty cells
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "headerxib", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "header")
        
        locateButton.isEnabled = false
        locateButton.alpha = 0.7
        
    }
    
    func setupHeader() {
        
//        profileImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
//        profileImage.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        changeProfilePictureButton.layer.cornerRadius = changeProfilePictureButton.frame.height/2
    }
    
    func displayUserData(){
        if let user = user{
            self.reference.child("users").child("\(user)" ).observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstname = (snapshot.value as AnyObject).value(forKey: "firstname") as? String, let lastname = (snapshot.value as AnyObject).value(forKey: "lastname") as? String{
                    self.firstName = firstname
                    self.lastName = lastname
                    self.fullNameLabel.text = "\(firstname)  \(lastname)"
                    self.accountCode.text = user
                    self.profileImage.image = UIImage(named: "user-placeholder")
                }
                
                self.tableView.reloadData()
                
            })
            self.reference.child("users").child("\(user)/buffer" ).observe(.value, with: { (snapshot) in
                self.reference.child("users").child("\(user)/imageUrl" ).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get download URL from snapshot
                    if let downloadUrl = snapshot.value as? String{
                        // Create a storage reference from the URL
                        let imageStorage = self.storageRef.reference(forURL: downloadUrl)
                        // Download the data, assuming a max size of 1MB (you can change this as necessary)
                        imageStorage.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                            if error == nil{
                                // Create a UIImage, add it to the array
                                self.profileImage.contentMode = .scaleAspectFill
                                self.profileImage.image = UIImage(data: data!)
                            }
                            else{
                                let alert = UIAlertController(title: "Upload Failed",
                                                              message: "File too big.",
                                                              preferredStyle: .alert)
                                
                                //alert with error
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                    self.tableView.reloadData()
                    
                })
                
            })
        }
    }
    
    func getFamilyCode(){
        if let currentUser = user{
            reference.child("users").child("\(currentUser)").child("families").observe( .value, with: { (snapshot) in
                
                self.familyRef.removeAll()
                self.families.removeAll()
                self.familyNames.removeAll()
                self.familyCodes.removeAll()
                for (section,familyCode) in snapshot.children.allObjects.enumerated(){
                    print(section)
                    self.families.append([])
                    self.familyCodes.append("")
                    self.familyNames.append("")
                    if let fc = familyCode as? DataSnapshot{
                        if let family = fc.key as? String{
                            self.familyRef.append(self.reference.child("family").child("\(family)"))
                            self.familyRef[section].observe( .value, with: { (snapshot) in
                                print(self.families.count)
                                print(section)
                                if self.families.count-1 < section{
                                    if self.familyRef.count != 0{
                                        for index in 0..<self.familyRef.count-1{
                                            self.familyRef[index].removeAllObservers()
                                        }
                                    }
                                }
                                if self.families.count-1 >= section{
                                    self.families[section] = []
                                    self.familyCodes[section] = ""
                                    self.familyNames[section] = ""
                                    //set name
                                    if let name = snapshot.childSnapshot(forPath: "name").value as? String{
                                        self.familyCodes[section] = family
                                        self.familyNames[section] = name
                                        self.tableView.reloadData()
                                    }
                                    
                                    
                                    if var snapshotKeys = (snapshot.childSnapshot(forPath: "members").value as? AnyObject)?.allKeys{
                                        print(snapshotKeys)
                                        for (index, snapshotKey) in (snapshotKeys.enumerated()){
                                            if self.user == snapshotKey as? String{
                                                snapshotKeys.remove(at: index)
                                            }
                                        }
                                        
                                        for (index, snapshotKey) in (snapshotKeys.enumerated()){
                                            self.families[section].append(Member())
                                            if let member = snapshotKey as? String{
                                                let memberReference = self.reference.child("users").child("\(member)")
                                                memberReference.observe( .value, with: { (snapshot) in
                                                    //set name
                                                    if let name = snapshot.value, self.families.count-1 >= section, self.families[section].count-1 >= index{
                                                        if let fName = (name as AnyObject) .value(forKey: "firstname") as? String, let lName = (name as AnyObject) .value(forKey: "lastname") as? String, let onlineCheck = (name as AnyObject) .value(forKey: "isOnline") as? String {
                                                            let fullname = ("\(fName) \(lName)")
                                                            print(fullname)
                                                            var holder = Member()
                                                            holder.key = member
                                                            holder.name = fullname
                                                            holder.firstName = fName
                                                            holder.status = onlineCheck
                                                            if let image = UIImage(named: "user-placeholder"){
                                                                if self.families[section][index].image != nil{
                                                                    holder.image = self.families[section][index].image
                                                                }
                                                                else{
                                                                        holder.image = image
                                                                }
                                                                
                                                            }
                                                            else{
                                                                holder.image = UIImage()
                                                            }
                                                            
                                                            self.families[section][index] = holder
                                                            self.tableView.reloadData()
                                                        }
                                                    }
                                                }) { print($0) }
                                                self.reference.child("users").child("\(member)").child("buffer").observe( .value, with: { (snapshot) in
                                                    self.reference.child("users").child("\(member)").child("imageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                                                        // Get download URL from snapshot
                                                        if let downloadUrl = snapshot.value as? String{
                                                            // Create a storage reference from the URL
                                                            let imageStorage = self.storageRef.reference(forURL: downloadUrl)
                                                            // Download the data, assuming a max size of 1MB (you can change this as necessary)
                                                            imageStorage.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                                                                if error == nil{
                                                                    // Create a UIImage, add it to the array
                                                                    if self.families.count-1 >= section{
                                                                        if self.families[section].count-1 >= index{
                                                                            self.families[section][index].image = UIImage(data: data!)!
                                                                        }
                                                                        self.tableView.reloadData()
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                    })
                                                })
                                            }
                                        }
                                    }
                                }
                                
                                self.tableView.reloadData()
                            }) { print($0) }
                        }
                    }
                }
                self.tableView.reloadData()
            }) { print($0) }
        }
    }
    
    func navBarModifications() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        parallaxHeader.view?.blurView.alpha = 1 - parallaxHeader.progress
        if parallaxHeader.progress == 0.000000{
            profileImage.frame.size = CGSize(width: 0, height: 0)
            changeProfilePictureButton.frame.size = CGSize(width: 0, height: 0)
            fullNameLabel.frame.size = CGSize(width: 0, height: 0)
            accountCode.frame.size = CGSize(width: 0, height: 0)
        }
        else{
            profileImage.frame.size = CGSize(width: 100, height: 100)
            changeProfilePictureButton.frame.size = CGSize(width:30, height: 30)
            fullNameLabel.frame.size = CGSize(width: headerView.frame.width, height: 26)
            accountCode.frame.size = CGSize(width: headerView.frame.width, height: 22)
        }
    }
    
    
    @IBAction func locate(_ sender: Any) {
        
        let map = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "mapScreen") as! MapViewController
        map.user = user
        map.firstName = self.firstName
        map.userImage = self.profileImage.image
        map.users = self.selectedUsers.mutableCopy() as? Array<String>
        map.userFirstNames =  self.selectedUsersFirstName.mutableCopy() as? Array<String>
        map.userImages = self.selectedUsersImages.mutableCopy() as? Array<UIImage>
        if let navigator = navigationController {
            navigator.pushViewController(map, animated: true)
        }
        
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "menuOptions") as! MenuOptionsTableViewController
        viewController.user = user
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: 60*4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.profileImage.image = UIImage(named: "user-placeholder")
        if let userCode = user {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let imageStorage = storageRef.reference().child("userImages/\(userCode)")
                let compressedImage = pickedImage.jpegData(compressionQuality: 0.3)
                imageStorage.putData(compressedImage!).observe(.success) { (snapshot) in
                    // When the image has successfully uploaded, we get its download URL
                    if let bucket = snapshot.metadata?.bucket, let name = snapshot.metadata?.name {
                        let downloadUrl = "gs://\(bucket)/userImages/\(name)"
                        // Write the download URL to the Realtime Database
                        let dbRefImg = self.reference.child("users/\(userCode)/imageUrl")
                        dbRefImg.setValue(downloadUrl)
                        let dbRefChg = self.reference.child("users/\(userCode)/buffer")
                        if let autoId = self.reference.childByAutoId().key {
                            dbRefChg.setValue(autoId)
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! HeaderXIB
        if families.count > 0{
            header.isHidden = false
            header.familyName.text = familyNames[section]
            header.familyCode.text = familyCodes[section]
            header.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.6963852048, green: 0.8679255843, blue: 0.8520774245, alpha: 1))
            
            header.familyOptions.tag = section
            header.familyOptions.addTarget(self, action: #selector(UserSelectionTableViewController.presentBottomSheet(_:)), for: .touchUpInside)
            return header
        }
        else{
            header.isHidden = true
            return header
        }
        
        
    }
    
    @objc func presentBottomSheet(_ sender: Any) {
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "familyOptions") as! FamilyOptionsTableViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        viewController.userCode = self.user
        viewController.familyCode = self.familyCodes[(sender as AnyObject).tag]
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: 60*3)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if families.count == 0{
            return 1
        }
        return familyCodes.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if families.count > 0{
            if families[section].isEmpty{
                return 1
            }
            else{
                return families[section].count
            }
        }
        else{
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if families.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
            tableView.separatorStyle = .singleLine
            
            if families[indexPath.section].count == 0{
                cell.membernameLabel.text = "No members available yet"
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.memberstatusLabel.isHidden = true
                cell.memberImageView.isHidden = true
                cell.statusIndicator.isHidden = true
            }
                
            else{
                cell.memberstatusLabel.isHidden = false
                cell.memberImageView.isHidden = false
                cell.statusIndicator.isHidden = false
                cell.isUserInteractionEnabled = true
                cell.selectionStyle = .default
                cell.memberImageView.backgroundColor = .gray
                cell.membernameLabel.text = families[indexPath.section][indexPath.row].name
                cell.memberImageView.image = families[indexPath.section][indexPath.row].image
                
                if families[indexPath.section][indexPath.row].status == "true"{
                    cell.memberstatusLabel.text = "online"
                    cell.statusIndicator.backgroundColor = .green
                }
                else{
                    cell.memberstatusLabel.text = "offline"
                    cell.statusIndicator.backgroundColor = .red
                }
            }
            return cell
        }
        else{
            let empty = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! EmptyTableViewCell
            tableView.separatorStyle = .none
            empty.isUserInteractionEnabled = false
            return empty
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if families[indexPath.section].count != 0{
            selectedCount += 1
            
            if selectedCount > 0{
                locateButton.isEnabled = true
                locateButton.alpha = 1
            }
            else{
                locateButton.isEnabled = false
                locateButton.alpha = 0.7
            }
            
            if selectedUsers.contains(families[indexPath.section][indexPath.row].key){
                let alert = UIAlertController(title: "Duplicate User",
                                              message: "User already selected.",
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                tableView.cellForRow(at: indexPath)?.isSelected = false
            }
            if selectedUsers.count > 5{
                let alert = UIAlertController(title: "Selected Users Exceeded Limit",
                                              message: "Only 5 users are allowed to be located at once",
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                tableView.cellForRow(at: indexPath)?.isSelected = false
            }
                
            else{
                if let key = families[indexPath.section][indexPath.row].key{
                    selectedUsers.add(key)
                }
                if let image = families[indexPath.section][indexPath.row].image{
                    selectedUsersImages.add(image)
                }
                if let firstName = families[indexPath.section][indexPath.row].firstName{
                    selectedUsersFirstName.add(firstName)
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if families[indexPath.section].count != 0{
            selectedCount -= 1
            
            if selectedCount > 0{
                locateButton.isEnabled = true
                locateButton.alpha = 1
            }
            else{
                locateButton.isEnabled = false
                locateButton.alpha = 0.7
            }
            
            if let key = families[indexPath.section][indexPath.row].key{
                selectedUsers.remove(key)
            }
            if let image = families[indexPath.section][indexPath.row].image{
                selectedUsersImages.remove(image)
            }
            if let firstName = families[indexPath.section][indexPath.row].firstName{
                selectedUsersFirstName.remove(firstName)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let memberKey = families[indexPath.section][indexPath.row].key, let familyKey = familyCodes[indexPath.section] as? String{
                
                
                self.reference.child("users").child(memberKey).child("families").child(familyKey).removeValue()
                self.reference.child("family").child(familyKey).child("members").child("\(memberKey)").removeValue()
                
                let fullname = families[indexPath.section][indexPath.row].name
                let message = "You have removed \(fullname) from \(self.familyNames[indexPath.section])"
                
                self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
                
                let message2 = "You have been removed from \(self.familyNames[indexPath.section])"
                
                self.reference.child("notifications").child(memberKey).child("notifications").childByAutoId().setValue(message2)
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if families.count != 0{
            if families[indexPath.section].count == 0{
                return UITableViewCell.EditingStyle.none
            }
            else{
                return UITableViewCell.EditingStyle.delete
            }
        }
        else{
            return UITableViewCell.EditingStyle.none
        }
        
    }
}
