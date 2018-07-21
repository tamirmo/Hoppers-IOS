//
//  LevelLogic.swift
//  Hoppers
//
//  Representing a level in the game with it's difficulty, id and starting state.
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

public class LevelLogic{
    
    // MARK: - Consts
    
    private static let SOLUTION_HOPS_SEPARATOR: String = "|"
    private static let GREEN_FROGS_SEPARATOR: String = "%"
    
    // MARK: - Members
    
    private var difficulty: GameManager.Difficulty
    private var id: Int
    
    // The locating of all frog at the initial state of this level
    private var redFrogLocation: Int
    private var greenFrogsLocations: [Int]
    
    private var solution: [Hop]
    
    // The record time the user solved the level
    private var recordSeconds: Int
    private var recordMinutes: Int
    private var recordHours: Int
    
    // Indicating if the user has viewed this level's solution
    private var isSolutionViewed: Bool
    
    // MARK: - Properties
    
    var Difficulty: GameManager.Difficulty{
        set{ difficulty = newValue }
        get{ return difficulty }
    }
    
    var Id: Int{
        set{ id = newValue }
        get{ return id }
    }
    
    var RedFrogLocation: Int{
        return redFrogLocation
    }
    
    var GreenFrogsLocations: [Int] {
        return greenFrogsLocations
    }
    
    var Solution: [Hop] {
        return solution
    }
    
    public var IsSolutionViewed: Bool{
        set{ isSolutionViewed = newValue }
        get{ return isSolutionViewed }
    }
    
    var RecordMinutes: Int{
        set{ recordMinutes = newValue }
        get{ return recordMinutes }
    }
    
    var RecordSeconds: Int{
        set{ recordSeconds = newValue }
        get{ return recordSeconds }
    }
    
    var RecordHours: Int{
        set{ recordHours = newValue }
        get{ return recordHours }
    }
    
    var IsSolved: Bool{
        return recordHours != 0 || recordMinutes != 0 || recordSeconds != 0
    }
    
    // MARK: - Ctors
    
    init(difficulty: GameManager.Difficulty,
         id: Int,
         
         // The locating of all frog at the initial state of this level
        redFrogLocation: Int,
        greenFrogsLocations: [Int],
        solution: [Hop],
        
        // The record time the user solved the level
        // (null if not yet solved)
        recordSeconds: Int,
        recordMinutes: Int,
        recordHours: Int,
        
        // Indicating if the user has viewed this level's solution
        isSolutionViewed: Bool){
        self.difficulty = difficulty
        self.redFrogLocation = redFrogLocation
        self.id = id
        self.greenFrogsLocations = greenFrogsLocations
        self.solution = solution
        self.recordHours = recordHours
        self.recordMinutes = recordMinutes
        self.recordSeconds = recordSeconds
        self.isSolutionViewed = isSolutionViewed
    }
    
    init(levelRecord: Level){
        self.difficulty = GameManager.Difficulty(id: levelRecord.Difficulty)!
        self.id = levelRecord.Id
        self.redFrogLocation = levelRecord.RedFrogLocation
        
        // Splitting the locations
        let frogsLocations: [String] = levelRecord.GreenFrogs.components(separatedBy: LevelLogic.GREEN_FROGS_SEPARATOR)
        
        // Adding each location to the array:
        self.greenFrogsLocations = [Int]()
        for currFrogLocation in frogsLocations {
            self.greenFrogsLocations.append(Int(currFrogLocation)!)
        }
        
        // Splitting the Hops
        let hops: [String] = levelRecord.Solution.components(separatedBy: LevelLogic.SOLUTION_HOPS_SEPARATOR)
        
        solution = [Hop]()
        
        // Adding each hop to the list:
        for hop in hops {
            solution.append(Hop(hopString: hop))
        }
        
        self.isSolutionViewed = levelRecord.IsSolutionViewed == 1
        
        self.recordSeconds = levelRecord.HighScoreSeconds
        self.recordMinutes = levelRecord.HighScoreMinutes
        self.recordHours = levelRecord.HighScoreHours
    }

    // MARK: - Methods
    
    public func getGreenFrogsString() -> String{
        var greenFrogsLocationsString: String = ""
        
        if self.greenFrogsLocations.count > 0 {
            for currFrogLocation in self.greenFrogsLocations{
                greenFrogsLocationsString = greenFrogsLocationsString + String(currFrogLocation)
                greenFrogsLocationsString = greenFrogsLocationsString + LevelLogic.GREEN_FROGS_SEPARATOR
            }
            
            // Removing last separator
            greenFrogsLocationsString = String(greenFrogsLocationsString.dropLast())
        }
        return greenFrogsLocationsString
    }
    
    public func getSolutionString() -> String{
        var solutionString: String = ""
        
        if self.solution.count > 0 {
            for currHop in solution{
                solutionString = solutionString + currHop.string
                solutionString = solutionString + LevelLogic.SOLUTION_HOPS_SEPARATOR
            }
            
            // Removing last separator
            solutionString = String(solutionString.dropLast())
        }
        
        return solutionString
    }
    
    var string: String {
        return String(format: "%02d:%02d:%02d", self.recordHours, self.recordMinutes, self.recordSeconds)
    }
}
