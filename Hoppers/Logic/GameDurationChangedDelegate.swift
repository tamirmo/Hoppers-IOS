//
//  GameDurationChangedDelegate.swift
//  Hoppers
//
//  Created by Tamir on 07/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

protocol GameDurationChangedDelegate: class {
    func gameDurationChanged(duration: String) -> Void
}
