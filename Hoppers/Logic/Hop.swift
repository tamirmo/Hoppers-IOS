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
    
    // MARK: - Members
    
    private var frogOriginalLeaf: LeafCoord
    private var frogHoppedLeaf: LeafCoord
    private var eatenFrogLeaf: LeafCoord
    
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
    
    // MARK: - Ctors
    
    init(frogOriginalLeaf: LeafCoord, frogHoppedLeaf: LeafCoord, eatenFrogLeaf: LeafCoord){
        self.frogOriginalLeaf = frogOriginalLeaf
        self.frogHoppedLeaf = frogHoppedLeaf
        self.eatenFrogLeaf = eatenFrogLeaf
    }
    
    init(hopString: String){
        let coordinates: [String] = hopString.components(separatedBy: Hop.HOP_SEPARATOR)
        frogOriginalLeaf = LeafCoord(coordinateString: coordinates[0])
        frogHoppedLeaf = LeafCoord(coordinateString: coordinates[1])
        eatenFrogLeaf = LeafCoord(coordinateString: coordinates[2])
    }
    
    var string: String {
        return String(describing: frogOriginalLeaf.string + Hop.HOP_SEPARATOR + frogHoppedLeaf.string + Hop.HOP_SEPARATOR + eatenFrogLeaf.string)
    }
}
