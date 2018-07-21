//
//  Turn.swift
//  Hoppers
//
//  Representing a game turn consist of a hop and a result.
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

class Turn{
    // MARK: - Enums
    
    enum TurnResult {
        case Hop
        case InvalidHop
        case GameWon
    }
    
    // MARK: - Members
    
    private var result: TurnResult
    private var hop: Hop?
    
    // MARK: - Ctors
    
    init(result: TurnResult, hop: Hop?){
        self.result = result
        self.hop = hop
    }
    
    // MARK: - Property
    
    var Result: TurnResult {
        set{ self.result = newValue }
        get{ return self.result }
    }
    
    var Hop: Hop? {
        set{ self.hop = newValue }
        get{ return self.hop }
    }
}
