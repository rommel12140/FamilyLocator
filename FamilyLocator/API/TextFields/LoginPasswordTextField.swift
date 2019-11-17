//
//  PasswordTextField.swift
//  FamilyLocator
//
//  Created by Rommel Gallofin on 16/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import MaterialComponents.MDCTextField

class LoginPasswordTextField: MDCTextField {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func setup(){
        placeholder = "Password"
        password
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
