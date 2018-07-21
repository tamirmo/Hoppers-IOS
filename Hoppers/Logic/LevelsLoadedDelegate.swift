//
//  LevelsLoadedDelegate.swift
//  Hoppers
//
//  Created by Tamir on 07/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

protocol LevelsLoadedDelegate: class{
    func levelsLoaded(levels: [LevelLogic]) -> Void
}
