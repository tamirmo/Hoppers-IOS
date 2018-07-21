//
//  Extension.swift
//  Hoppers
//
//  Created by Tamir on 14/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import UIKit

extension UIControl {
    var borderUIColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
}
