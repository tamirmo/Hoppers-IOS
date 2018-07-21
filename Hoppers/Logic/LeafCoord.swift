//
//  LeafCoord.swift
//  Hoppers
//
//  Representing a coordinate of a cell in the swamp (belongs to a leaf).
//  
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

class LeafCoord{
    // MARK: - Consts
    
    public static let SWAMP_LEAVES: Int = 13
    private static let COORFINATE_SEPAERATOR: String = "#"
    public static let EVEN_ROW_FROGS: Int = 3
    public static let ODD_ROW_FROGS: Int = 2
    
    // MARK: - Members
    
    private var row: Int = 0
    private var column: Int = 0
    
    // MARK: - Properties
    
    var Row: Int{
        set{ row = newValue }
        get{ return row }
    }
    
    var Column: Int{
        set{ column = newValue }
        get{ return column }
    }
    
    init(row: Int, column: Int){
        self.column = column
        self.row = row
    }
    
    init(cellIndex: Int){
        var indexCopy: Int = cellIndex
        var currRow: Int = 0
        
        // Subtracting the columns in each row until reaching zero
        while (indexCopy >= 0){
            if(currRow % 2 == 0){
                indexCopy -= LeafCoord.EVEN_ROW_FROGS
            }
            else{
                indexCopy -= LeafCoord.ODD_ROW_FROGS
            }
            currRow += 1
        }
        
        // The last increment was wrong
        currRow -= 1
        
        // To get the column, we need to add the last row's count:
        
        if(currRow % 2 == 0){
            indexCopy += LeafCoord.EVEN_ROW_FROGS
        }
        else{
            indexCopy += LeafCoord.ODD_ROW_FROGS
        }
        
        self.row = currRow
        self.column = indexCopy
    }
    
    init(coordinateString: String){
        // Checking if there is row, separator, column
        if(coordinateString.count == 3){
            // Separating the row and the column
            let splitCoordinate: [String] = coordinateString.components(separatedBy: LeafCoord.COORFINATE_SEPAERATOR)
            // Checking if there is a row and a column
            if(splitCoordinate.count == 2){
                row = Int(splitCoordinate[0])!
                column = Int(splitCoordinate[1])!
            }
        }
    }
    
    // MARK: - Methods
    
    public func getCellIndex() -> Int{
        return LeafCoord.getCellIndex(row: row, col: column)
    }
    
    static func getCellIndex(row: Int, col:Int) -> Int{
        var index: Int = 0
        
        if row >= 0 {
            // Adding the cells in the previous rows
            for i in 0..<row {
                // Even rows has 3 columns
                if i % 2 == 0 {
                    index += LeafCoord.EVEN_ROW_FROGS
                }
                // Odd rows have 2 columns
                else{
                    index += LeafCoord.ODD_ROW_FROGS
                }
            }
        }
        index += col
        
        return index
    }
    
    var string: String {
        return String(describing: String(row) + LeafCoord.COORFINATE_SEPAERATOR + String(column))
    }
}
