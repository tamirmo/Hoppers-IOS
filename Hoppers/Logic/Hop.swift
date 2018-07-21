//
//  Hop.swift
//  Hoppers
//
// Representing one turn - one frog hop from one leaf to another
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

class Hop{

    // MARK: - Const
    
    private static let HOP_SEPARATOR: String = ","
    
    // MARK: - Enums
    
    public enum HopType {
        case Left
        case Right
        case Down
        case Up
        case LeftUp
        case LeftDown
        case RightUp
        case RightDown
    }
    
    // MARK: - Members
    
    private var frogOriginalLeaf: LeafCoord
    private var frogHoppedLeaf: LeafCoord
    private var eatenFrogLeaf: LeafCoord
    private var hopType: HopType?
    
    // MARK: - Properties
    
    var FrogOriginalLeaf: LeafCoord {
        return self.frogOriginalLeaf
    }
    
    var FrogHoppedLeaf: LeafCoord {
        return self.frogHoppedLeaf
    }
    
    var EatenFrogLeaf: LeafCoord {
        return self.eatenFrogLeaf
    }
    
    var HopType: HopType {
        return self.hopType!
    }
    
    // MARK: - Ctors
    
    init(frogOriginalLeaf: LeafCoord, frogHoppedLeaf: LeafCoord, eatenFrogLeaf: LeafCoord){
        self.frogOriginalLeaf = frogOriginalLeaf
        self.frogHoppedLeaf = frogHoppedLeaf
        self.eatenFrogLeaf = eatenFrogLeaf
        
        self.hopType = evaluateHopType()
    }
    
    init(hopString: String){
        let coordinates: [String] = hopString.components(separatedBy: Hop.HOP_SEPARATOR)
        frogOriginalLeaf = LeafCoord(coordinateString: coordinates[0])
        frogHoppedLeaf = LeafCoord(coordinateString: coordinates[1])
        eatenFrogLeaf = LeafCoord(coordinateString: coordinates[2])
        
        hopType = evaluateHopType()
    }
    
    // MARK: - Methods
    
    private func evaluateHopType() -> HopType{
        var type: HopType
        
        // If the rows are the same it is left or right hop:
        if frogOriginalLeaf.Row ==  frogHoppedLeaf.Row{
            if frogOriginalLeaf.Column <  frogHoppedLeaf.Column {
                type = HopType.Right
            }
            else {
                type = HopType.Left
            }
        }
        // If the cols are the same it is up or down hop:
        else if frogOriginalLeaf.Column ==  frogHoppedLeaf.Column {
        
            if frogOriginalLeaf.Row <  frogHoppedLeaf.Row {
                type = HopType.Down
            }
            else {
                type = HopType.Up
            }
        }
        // If not the same then we have a diagonal hop:
        else{
            if frogOriginalLeaf.Row <  frogHoppedLeaf.Row &&
                frogOriginalLeaf.Column <  frogHoppedLeaf.Column {
                type = HopType.RightDown
            }
            else if frogOriginalLeaf.Row <  frogHoppedLeaf.Row &&
                frogOriginalLeaf.Column >  frogHoppedLeaf.Column {
                type = HopType.LeftDown
            }
            else if frogOriginalLeaf.Column <  frogHoppedLeaf.Column{
                type = HopType.RightUp
            }
            else{
                type = HopType.LeftUp
            }
        }
        
        return type
    }
    
    var string: String {
        return String(describing: frogOriginalLeaf.string + Hop.HOP_SEPARATOR + frogHoppedLeaf.string + Hop.HOP_SEPARATOR + eatenFrogLeaf.string)
    }
}
