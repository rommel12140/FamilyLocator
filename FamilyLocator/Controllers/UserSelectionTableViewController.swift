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
import MaterialComponents.MaterialBottomSheet_ShapeThemer

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate {

    let tempFamily:NSArray = ["CCS Family", "Friends"]
    let tempCodes:NSArray = ["ccsfamily-1122", "friends-2233"]
    let tempUserArray:NSArray = [["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Section 1"], ["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Section 2"]]

    @IBOutlet weak var background: UIImageView!
    let profileImage = UIImageView()
    let fullnameLabel = UILabel()
    let accountCode = UILabel()
    let locateButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupHeader()
        navBarModifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        setupHeader()
        tableView.parallaxHeader.minimumHeight = view.safeAreaInsets.top + 100
    }
    
    func setup() {
        tableView.estimatedRowHeight = 100
//        headerView.frame.size = CGSize(width: tableView.frame.width, height: tableView.frame.height)
//    headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.contentMode = .scaleAspectFit
        
        
        // Parallax Header
        tableView.parallaxHeader.view = background // You can set the parallax header view from the floating view
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
        profileImage.frame = CGRect(x: background.frame.midX - 50, y: 20, width: 100, height: 100)
        profileImage.image = UIImage(named: "spiderman")
        background.addSubview(profileImage)
        
        locateButton.frame = CGRect(x: 0, y: background.frame.maxY - 100, width: background.frame.width, height: 100)
        locateButton.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.4039205313, green: 0.593059063, blue: 0.603407383, alpha: 1))
        locateButton.setTitle("Locate", for: .normal)
        background.addSubview(locateButton)
    }
    
    func navBarModifications() {
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        NSLog("progress %f", parallaxHeader.progress)
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
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "test") as! FamilyOptionsViewController
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
