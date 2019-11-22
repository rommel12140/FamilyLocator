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

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var users: String!
    let tempFamily:NSArray = ["CCS Family", "Friends"]
    let tempCodes:NSArray = ["ccsfamily-1122", "friends-2233"]
    let tempUserArray:NSArray = [["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Section 1"], ["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Section 2"]]

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var accountCode: UILabel!
    @IBOutlet weak var locateButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
        setupHeader()
        getData()
        navBarModifications()
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        setupHeader()
        tableView.parallaxHeader.minimumHeight = view.safeAreaInsets.top + locateButton.frame.height
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
        
    }
    
    func setupHeader() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        changeProfilePictureButton.layer.cornerRadius = changeProfilePictureButton.frame.height/2
    }
    
    func getData(){
        let reference = Database.database().reference()
        if let user = users as? String{
            reference.child("users").child("\(user)" as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstname = (snapshot.value as AnyObject).value(forKey: "firstname") as? String, let lastname = (snapshot.value as AnyObject).value(forKey: "lastname") as? String{
                    self.fullNameLabel.text = "\(firstname)  \(lastname)"
                    self.accountCode.text = user
                    self.tableView.reloadData()
                }
                
            })
        }
        
    }
    
    func navBarModifications() {
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        NSLog("progress %f", parallaxHeader.progress)
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
        self.present(map, animated: true, completion: nil)
        
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "menuOptions") as! MenuOptionsTableViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height/4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        print("nipress?")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.contentMode = .scaleAspectFill
            profileImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! HeaderXIB
        header.familyName.text = (tempFamily.object(at: section) as! String)
        header.familyCode.text = (tempCodes.object(at: section) as! String)
        header.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.6963852048, green: 0.8679255843, blue: 0.8520774245, alpha: 1))
        
        header.familyOptions.addTarget(self, action: #selector(UserSelectionTableViewController.presentBottomSheet), for: .touchUpInside)
        
        return header
    }
    
    @objc func presentBottomSheet( _sender: UIButton) {
        // Initialize the bottom sheet with the view controller just created
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "familyOptions") as! FamilyOptionsViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height/4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tempFamily.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return (tempUserArray.object(at: section) as AnyObject).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        switch indexPath.row % 2 {
        case 0:
            cell.membernameLabel.text = ((tempUserArray.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! String)
            cell.memberImageView.image = UIImage(named: "spiderman")
            cell.memberstatusLabel.text = "Online"
        default:
            cell.contentView.backgroundColor = UIColor.white
            cell.membernameLabel.text = ((tempUserArray.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! String)
            cell.memberImageView.image = UIImage(named: "spiderman")
            cell.memberstatusLabel.text = "Offline"
            cell.membernameLabel.textColor = UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(tempUserArray.object(at: indexPath.section))
            let sec:Int = indexPath.section
            (tempUserArray[sec] as AnyObject).removeObject(at: indexPath.row)
            print(tempUserArray)
        }
    }
}
