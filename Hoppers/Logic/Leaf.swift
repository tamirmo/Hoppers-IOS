//
//  Leaf.swift
//  Hoppers
//
//  Representing a cell in the game board.
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

class Leaf{
    
    // MARK: - Enums
    
    enum LeafType: Int {
        case Empty
        case RedFrog
        case GreenFrog
        
        static let allValues = [Empty, RedFrog, GreenFrog]
        
        init?(id : Int) {
            switch id {
            case 1:
                self = .Empty
            case 2:
                self = .RedFrog
            case 3:
                self = .GreenFrog
            default:
                return nil
            }
        }
    }
    
    // MARK: - Members
    
    private var leafType: LeafType
    private var isSelcted: Bool
    private var isValidHop: Bool
    
    // MARK: - Properties
    
    var LeafType: LeafType{
        set{ leafType = newValue }
        get{ return leafType }
    }
    
    var IsSelected: Bool{
        set{ isSelcted = newValue }
        get{ return isSelcted }
    }
    
    var IsValidHop: Bool{
        set{ isValidHop = newValue }
        get{ return isValidHop }
    }
    
    // MARK: - Ctor
    
    init(){
        leafType = .Empty
        isSelcted = false
        isValidHop = false
    }
}
