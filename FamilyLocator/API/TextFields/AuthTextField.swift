//
//  LoginEmailTextField.swift
//  FamilyLocator
//
//  Created by Rommel Gallofin on 16/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class AuthTextField: SkyFloatingLabelTextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setup(){
        frame.size.height = 50
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
