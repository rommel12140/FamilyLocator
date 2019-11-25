//
//  MapInfo.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 20/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class MapInfo: UIView {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStreet: UILabel!
    @IBOutlet weak var userCity: UILabel!
    @IBOutlet weak var userCountry: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var userNumber: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBAction func routeButton(_ sender: Any) {
        print("userNumber")
    }
}
