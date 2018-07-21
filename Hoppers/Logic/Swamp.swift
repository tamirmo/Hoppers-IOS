//
//  Swamp.swift
//  Hoppers
//
//  A class representing the game board.
//  The game board consists of leafs and frogs.
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

class Swamp{
    
    // MARK: - Consts
    
    public static let NUM_OF_ROWS: Int = 5
    
    // MARK: - Members
    
    private var leaves: [[Leaf]] = [[Leaf]]()
    private var selectedFrogCord: LeafCoord?
    
    // MARK: - Properties
    
    var SelectedFrogCord: LeafCoord?{
        get{ return selectedFrogCord }
    }
    
    // MARK: - Ctors
    
    init(){
        // Initializing the swamp (even rows have 3 leaves and odd have 2 leaves)
        leaves = [Array(repeating: Leaf(), count: 3),
                  Array(repeating: Leaf(), count: 2),
                  Array(repeating: Leaf(), count: 3),
                  Array(repeating: Leaf(), count: 2),
                  Array(repeating: Leaf(), count: 3)]
    }
    
    // MARK: - Methods
    
    public func setLevel(level: LevelLogic){
     
        // Emptying all leaves
        for i in 0..<leaves.count {
            for j in 0..<leaves[i].count {
                leaves[i][j] = Leaf()
                leaves[i][j].LeafType = Leaf.LeafType.Empty
                leaves[i][j].IsValidHop = false
                leaves[i][j].IsSelected = false
            }
        }
     
        // Setting the green frogs
        let greenFrogsLocations: [Int] = level.GreenFrogsLocations
        for i in 0..<level.GreenFrogsLocations.count {
            getLeaf(coordinate: LeafCoord(cellIndex: greenFrogsLocations[i]))?.LeafType = Leaf.LeafType.GreenFrog
        }
     
        // Setting red frog
        getLeaf(coordinate: LeafCoord(cellIndex: level.RedFrogLocation))?.LeafType = Leaf.LeafType.RedFrog
    }
    
    func getLeaf(coordinate: LeafCoord) -> Leaf?{
        var leaf: Leaf? = nil
    
        // Checking if the indexes represent valid leaves
        if(coordinate.Row >= 0 &&
            coordinate.Column >= 0 &&
            leaves.count > coordinate.Row &&
            leaves[coordinate.Row].count > coordinate.Column){
                // Getting the leaf in the desired space
                leaf = leaves[coordinate.Row][coordinate.Column]
            }
    
        return leaf
    }
    
    func makeHop(hop: Hop){
        getLeaf(coordinate: hop.EatenFrogLeaf)?.LeafType = Leaf.LeafType.Empty
        // Getting the hopped frog and clearing it's original leaf
        let frog: Leaf.LeafType = getLeaf(coordinate: hop.FrogOriginalLeaf)!.LeafType
        getLeaf(coordinate: hop.FrogOriginalLeaf)?.LeafType = Leaf.LeafType.Empty
    
        // Setting the destination leaf with the hopped frog
        getLeaf(coordinate: hop.FrogHoppedLeaf)?.LeafType = frog
    
        clearSelectedLeaf()
    }
    
    /**
     * Setting no selected leaf and setting all leaves as non valid for hop
     */
    func clearSelectedLeaf(){
        selectedFrogCord = nil
    
        // Clearing last selected:
    
        for i in 0..<leaves.count{
            for j in 0..<leaves[i].count{
                leaves[i][j].IsSelected = false
                leaves[i][j].IsValidHop = false
            }
        }
    }
    
    /**
      Reverting the given hop.
      Called when stepping backwards from a solution.
      - Parameter hop: The hop to revert
     */
    func revertHop(hop: Hop){
        // Getting the green frog back
        getLeaf(coordinate: hop.EatenFrogLeaf)?.LeafType = Leaf.LeafType.GreenFrog
        // Getting the hopped frog and clearing it's current leaf
        let frog: Leaf.LeafType = getLeaf(coordinate: hop.FrogHoppedLeaf)!.LeafType
        getLeaf(coordinate: hop.FrogHoppedLeaf)?.LeafType = Leaf.LeafType.Empty
    
        // Setting the original leaf with the hopped frog
        getLeaf(coordinate: hop.FrogOriginalLeaf)?.LeafType = frog
    
        clearSelectedLeaf()
    }
    
    func selectLeaf(coordinate: LeafCoord){
        let leaf: Leaf? = getLeaf(coordinate: coordinate)
        if leaf != nil{
            if(leaf!.LeafType != Leaf.LeafType.Empty){
                // Clearing last selected:
    
                for i in 0..<leaves.count{
                    for j in 0..<leaves[i].count{
                        leaves[i][j].IsSelected = false
                        leaves[i][j].IsValidHop = false
                    }
                }
    
                setValidHops(selectedFrogLeaf: coordinate)
    
                leaf!.IsSelected = true
                selectedFrogCord = coordinate
            }
        }
    }
    
    private func setValidHops(selectedFrogLeaf: LeafCoord){
    
        let selectedFrogRow: Int = selectedFrogLeaf.Row
        let selectedFrogColumn: Int = selectedFrogLeaf.Column
    
        // Tf the frog is a row with 3 columns
        if(selectedFrogLeaf.Row % 2 == 0){
            // Handling the "straight" hop
            // (not available for frogs in a row with two leaves):
    
            // Hop down
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow + 4, column: selectedFrogColumn),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn)){
    
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow + 4, column: selectedFrogColumn))!.IsValidHop = true
        }
    
        // Hop up
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow - 4, column: selectedFrogColumn),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow - 4, column: selectedFrogColumn))!.IsValidHop = true
        }
    
        // Hop right
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn + 2),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn + 1)){
    
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn + 2))!.IsValidHop = true
        }
    
        // Hop left
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn - 2),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn - 1)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow, column: selectedFrogColumn - 2))!.IsValidHop = true
        }
    
        // Handling the "diagonal" hop:
    
        // Diagonal down left
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn - 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow + 1, column: selectedFrogColumn - 1)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn - 1))!.IsValidHop = true
        }
    
        // Diagonal down right
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn + 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow + 1, column: selectedFrogColumn)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn + 1))!.IsValidHop = true
        }
    
        // Diagonal up left
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn - 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow - 1, column: selectedFrogColumn - 1)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn - 1))!.IsValidHop = true
        }
    
        // Diagonal up right
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn + 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow - 1, column: selectedFrogColumn)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn + 1))!.IsValidHop = true
        }
        }else{
        // Handling the "diagonal" hop:
    
        // Diagonal down left
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn - 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow + 1, column: selectedFrogColumn)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn - 1))!.IsValidHop = true
        }
    
        // Diagonal down right
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn + 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow + 1, column: selectedFrogColumn + 1)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow + 2, column: selectedFrogColumn + 1))!.IsValidHop = true
        }
    
        // Diagonal up left
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn - 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow - 1, column: selectedFrogColumn)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn - 1))!.IsValidHop = true
        }
    
        // Diagonal up right
            if isValidHop(destinationLeaf: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn + 1),
                          eatenFrogLeaf: LeafCoord(row: selectedFrogRow - 1, column: selectedFrogColumn + 1)){
                getLeaf(coordinate: LeafCoord(row: selectedFrogRow - 2, column: selectedFrogColumn + 1))!.IsValidHop = true
        }
        }
    }
    
    /**
     Checking if the given destination is an empty leaf and the eatenFrogLeaf contains a green frog
     - Parameter destinationLeaf: The coordinates of the leaf hopping to
     - Parameter eatenFrogLeaf: The coordinates of the leaf holding the hopped upon frog (eaten)
     - returns: True if given destination is an empty leaf and the eatenFrogLeaf contains a green frog, False otherwise
     */
    private func isValidHop(destinationLeaf: LeafCoord, eatenFrogLeaf: LeafCoord) -> Bool{
        var isValidHop: Bool = false
    
        if(getLeaf(coordinate: destinationLeaf) != nil &&
            getLeaf(coordinate: destinationLeaf)!.LeafType == Leaf.LeafType.Empty &&
            getLeaf(coordinate: eatenFrogLeaf) != nil &&
            getLeaf(coordinate: eatenFrogLeaf)!.LeafType == Leaf.LeafType.GreenFrog){
            isValidHop = true
        }
    
        return isValidHop
    }
    
    /**
     Checking if the given destination is an empty leaf and the eatenFrogLeaf contains a green frog
     - returns: True if only red frog, False otherwise
     */
    func isOnlyRedFrog() -> Bool{
        var isOnlyRedFrog:Bool = true
    
        for i in 0..<leaves.count{
            for j in 0..<leaves[i].count{
                if leaves[i][j].LeafType == Leaf.LeafType.GreenFrog {
                    isOnlyRedFrog = false
                }
            }
        }
    
        return  isOnlyRedFrog
    }
}
