//
//  HeaderXIB.swift
//  FamilyLocator
//
//  Created by Action Trainee on 19/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class HeaderXIB: UITableViewHeaderFooterView {

    @IBOutlet weak var familyName: UILabel!
    
    @IBOutlet weak var familyCode: UILabel!
    
    @IBOutlet weak var familyOptions: UIButton!
    
    @IBAction func showFamilyOptions(_ sender: Any) {
        print("it works")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        familyOptions.setBackgroundImage(#imageLiteral(resourceName: "ActionOverflow"), for: .normal)
        familyOptions.setBackgroundImage(#imageLiteral(resourceName: "ActionOverflow"), for: .highlighted)
        
        
    }
}
