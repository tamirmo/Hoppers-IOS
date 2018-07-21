//
//  LevelsLoader.swift
//  Hoppers
//
//  Loading the levels from the database or inserting if not exist yet.
//  
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
class LevelsLoader : LevelsDelegate{
    
    // MARK: - Static maps
    
    private static var hopsMap: [String: Hop] = [:]
    private static var leavesCordsMap: [String: LeafCoord] = [:]
    
    // MARK: - Cordinates
    
    // Each letter represents a coordinate of a leaf:
    private static let A: LeafCoord = LeafCoord(row: 0, column: 0)
    private static let B: LeafCoord = LeafCoord(row: 0, column: 1)
    private static let C: LeafCoord = LeafCoord(row: 0, column: 2)
    private static let D: LeafCoord = LeafCoord(row: 1, column: 0)
    private static let E: LeafCoord = LeafCoord(row: 1, column: 1)
    private static let F: LeafCoord = LeafCoord(row: 2, column: 0)
    private static let G: LeafCoord = LeafCoord(row: 2, column: 1)
    private static let H: LeafCoord = LeafCoord(row: 2, column: 2)
    private static let I: LeafCoord = LeafCoord(row: 3, column: 0)
    private static let J: LeafCoord = LeafCoord(row: 3, column: 1)
    private static let K: LeafCoord = LeafCoord(row: 4, column: 0)
    private static let L: LeafCoord = LeafCoord(row: 4, column: 1)
    private static let M: LeafCoord = LeafCoord(row: 4, column: 2)
    
    // MARK: - Hops
    
    // Creating a hop for each hop possible to use when reading solutions
    private static let A_C: Hop = Hop(frogOriginalLeaf: A, frogHoppedLeaf: C, eatenFrogLeaf: B)
    private static let A_G: Hop = Hop(frogOriginalLeaf: A, frogHoppedLeaf: G, eatenFrogLeaf: D)
    private static let A_K: Hop = Hop(frogOriginalLeaf: A, frogHoppedLeaf: K, eatenFrogLeaf: F)
    private static let B_F: Hop = Hop(frogOriginalLeaf: B, frogHoppedLeaf: F, eatenFrogLeaf: D)
    private static let B_H: Hop = Hop(frogOriginalLeaf: B, frogHoppedLeaf: H, eatenFrogLeaf: E)
    private static let B_L: Hop = Hop(frogOriginalLeaf: B, frogHoppedLeaf: L, eatenFrogLeaf: G)
    private static let C_A: Hop = Hop(frogOriginalLeaf: C, frogHoppedLeaf: A, eatenFrogLeaf: B)
    private static let C_M: Hop = Hop(frogOriginalLeaf: C, frogHoppedLeaf: M, eatenFrogLeaf: H)
    private static let C_G: Hop = Hop(frogOriginalLeaf: C, frogHoppedLeaf: G, eatenFrogLeaf: E)
    private static let D_J: Hop = Hop(frogOriginalLeaf: D, frogHoppedLeaf: J, eatenFrogLeaf: G)
    private static let E_I: Hop = Hop(frogOriginalLeaf: E, frogHoppedLeaf: I, eatenFrogLeaf: G)
    private static let F_H: Hop = Hop(frogOriginalLeaf: F, frogHoppedLeaf: H, eatenFrogLeaf: G)
    private static let F_L: Hop = Hop(frogOriginalLeaf: F, frogHoppedLeaf: L, eatenFrogLeaf: I)
    private static let F_B: Hop = Hop(frogOriginalLeaf: F, frogHoppedLeaf: B, eatenFrogLeaf: D)
    private static let G_M: Hop = Hop(frogOriginalLeaf: G, frogHoppedLeaf: M, eatenFrogLeaf: J)
    private static let G_K: Hop = Hop(frogOriginalLeaf: G, frogHoppedLeaf: K, eatenFrogLeaf: I)
    private static let G_C: Hop = Hop(frogOriginalLeaf: G, frogHoppedLeaf: C, eatenFrogLeaf: E)
    private static let G_A: Hop = Hop(frogOriginalLeaf: G, frogHoppedLeaf: A, eatenFrogLeaf: D)
    private static let H_L: Hop = Hop(frogOriginalLeaf: H, frogHoppedLeaf: L, eatenFrogLeaf: J)
    private static let H_B: Hop = Hop(frogOriginalLeaf: H, frogHoppedLeaf: B, eatenFrogLeaf: E)
    private static let H_F: Hop = Hop(frogOriginalLeaf: H, frogHoppedLeaf: F, eatenFrogLeaf: G)
    private static let I_E: Hop = Hop(frogOriginalLeaf: I, frogHoppedLeaf: E, eatenFrogLeaf: G)
    private static let J_D: Hop = Hop(frogOriginalLeaf: J, frogHoppedLeaf: D, eatenFrogLeaf: G)
    private static let K_A: Hop = Hop(frogOriginalLeaf: K, frogHoppedLeaf: A, eatenFrogLeaf: F)
    private static let K_M: Hop = Hop(frogOriginalLeaf: K, frogHoppedLeaf: M, eatenFrogLeaf: L)
    private static let K_G: Hop = Hop(frogOriginalLeaf: K, frogHoppedLeaf: G, eatenFrogLeaf: I)
    private static let L_F: Hop = Hop(frogOriginalLeaf: L, frogHoppedLeaf: F, eatenFrogLeaf: I)
    private static let L_H: Hop = Hop(frogOriginalLeaf: L, frogHoppedLeaf: H, eatenFrogLeaf: J)
    private static let L_B: Hop = Hop(frogOriginalLeaf: L, frogHoppedLeaf: B, eatenFrogLeaf: G)
    private static let M_K: Hop = Hop(frogOriginalLeaf: M, frogHoppedLeaf: K, eatenFrogLeaf: L)
    private static let M_G: Hop = Hop(frogOriginalLeaf: M, frogHoppedLeaf: G, eatenFrogLeaf: J)
    private static let M_C: Hop = Hop(frogOriginalLeaf: M, frogHoppedLeaf: C, eatenFrogLeaf: H)
    
    // MARK: - Members
    
    private var levels: [LevelLogic]
    private var levelsDbHelper: LevelsDbHelper
    public weak var levelsLoadedDelegate: LevelsLoadedDelegate?
    
    // MARK: - Ctors
    
    init(levelsDbHelper: LevelsDbHelper){
        self.levelsDbHelper = levelsDbHelper
        levels = [LevelLogic]()
    }
    
    // MARK: - Methods
    
    func loadLevels(){
        // Getting the levels from the database
        levelsDbHelper.getLevels(levelsDelegate: self)
    }
    
    private func initHopsMap(){
        LevelsLoader.hopsMap["A-C"] = LevelsLoader.A_C
        LevelsLoader.hopsMap["A-G"] = LevelsLoader.A_G
        LevelsLoader.hopsMap["A-K"] = LevelsLoader.A_K
        LevelsLoader.hopsMap["B-F"] = LevelsLoader.B_F
        LevelsLoader.hopsMap["B-H"] = LevelsLoader.B_H
        LevelsLoader.hopsMap["B-L"] = LevelsLoader.B_L
        LevelsLoader.hopsMap["C-A"] = LevelsLoader.C_A
        LevelsLoader.hopsMap["C-M"] = LevelsLoader.C_M
        LevelsLoader.hopsMap["C-G"] = LevelsLoader.C_G
        LevelsLoader.hopsMap["D-J"] = LevelsLoader.D_J
        LevelsLoader.hopsMap["E-I"] = LevelsLoader.E_I
        LevelsLoader.hopsMap["F-H"] = LevelsLoader.F_H
        LevelsLoader.hopsMap["F-L"] = LevelsLoader.F_L
        LevelsLoader.hopsMap["F-B"] = LevelsLoader.F_B
        LevelsLoader.hopsMap["G-M"] = LevelsLoader.G_M
        LevelsLoader.hopsMap["G-K"] = LevelsLoader.G_K
        LevelsLoader.hopsMap["G-A"] = LevelsLoader.G_A
        LevelsLoader.hopsMap["G-C"] = LevelsLoader.G_C
        LevelsLoader.hopsMap["H-L"] = LevelsLoader.H_L
        LevelsLoader.hopsMap["H-B"] = LevelsLoader.H_B
        LevelsLoader.hopsMap["H-F"] = LevelsLoader.H_F
        LevelsLoader.hopsMap["I-E"] = LevelsLoader.I_E
        LevelsLoader.hopsMap["J-D"] = LevelsLoader.J_D
        LevelsLoader.hopsMap["K-A"] = LevelsLoader.K_A
        LevelsLoader.hopsMap["K-M"] = LevelsLoader.K_M
        LevelsLoader.hopsMap["K-G"] = LevelsLoader.K_G
        LevelsLoader.hopsMap["L-F"] = LevelsLoader.L_F
        LevelsLoader.hopsMap["L-H"] = LevelsLoader.L_H
        LevelsLoader.hopsMap["L-B"] = LevelsLoader.L_B
        LevelsLoader.hopsMap["M-K"] = LevelsLoader.M_K
        LevelsLoader.hopsMap["M-G"] = LevelsLoader.M_G
        LevelsLoader.hopsMap["M-C"] = LevelsLoader.M_C
    }
    
    private func initLeavesCordMap(){
        LevelsLoader.leavesCordsMap["A"] = LevelsLoader.A
        LevelsLoader.leavesCordsMap["B"] = LevelsLoader.B
        LevelsLoader.leavesCordsMap["C"] = LevelsLoader.C
        LevelsLoader.leavesCordsMap["D"] = LevelsLoader.D
        LevelsLoader.leavesCordsMap["E"] = LevelsLoader.E
        LevelsLoader.leavesCordsMap["F"] = LevelsLoader.F
        LevelsLoader.leavesCordsMap["G"] = LevelsLoader.G
        LevelsLoader.leavesCordsMap["H"] = LevelsLoader.H
        LevelsLoader.leavesCordsMap["I"] = LevelsLoader.I
        LevelsLoader.leavesCordsMap["J"] = LevelsLoader.J
        LevelsLoader.leavesCordsMap["K"] = LevelsLoader.K
        LevelsLoader.leavesCordsMap["L"] = LevelsLoader.L
        LevelsLoader.leavesCordsMap["M"] = LevelsLoader.M
    }
    
    // Indicating the database already has the levels
    func levelsPulled(levels dbLevels: [Level]?) {
        levels = [LevelLogic]()
        
        // Adding the levels to the local list
        if(dbLevels != nil && dbLevels!.count > 0){
            // Converting the levels from DB to Level objects:
            for record in dbLevels!{
                self.levels.append(LevelLogic(levelRecord: record))
            }
        }
        // There are no levels in the DB
        else{
            addLevelsToDB()
        }
        
        // Updating the listener the loading is over
        levelsLoadedDelegate?.levelsLoaded(levels: levels)
    }
    
    func addLevelsToDB() {
        // Creating the levels:
        
        // Creating the maps helping with levels creations
        initHopsMap()
        initLeavesCordMap()
        
        // Initializing the levels in all the difficulties
        initializeBeginner()
        initializeIntermediate()
        initializeAdvanced()
        initializeExpert()
        
        // Adding each level to the DB
        for level in levels {
            let greenFrogs: String = level.getGreenFrogsString()
            let solution: String = level.getSolutionString()
            
            levelsDbHelper.addLevel(id: level.Id, difficulty: level.Difficulty.rawValue, redFrogLocation: level.RedFrogLocation,                       greenFrogs: greenFrogs, solution: solution)
        }
        
        // Updating the listener the loading is over
        levelsLoadedDelegate?.levelsLoaded(levels: levels)
    }
    
    private func initializeBeginner(){
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 1,
                                   greenFrogsLocations: "A,D,G",
                                   redFrogLocation: "I",
                                   solution: "I-E,A-G,E-I").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 2,
                                   greenFrogsLocations: "A,C,D,E",
                                   redFrogLocation: "F",
                                   solution: "A-G,F-H,C-G,H-F").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 3,
                                   greenFrogsLocations: "A,D,E,F",
                                   redFrogLocation: "G",
                                   solution: "G-C,A-G,F-H,C-M").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 4,
                                   greenFrogsLocations: "A,F,G,I",
                                   redFrogLocation: "H",
                                   solution: "A-K,H-F,K-G,F-H").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 5,
                                   greenFrogsLocations: "G,H,I,L",
                                   redFrogLocation: "A",
                                   solution: "L-F,A-K,H-F,K-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 6,
                                   greenFrogsLocations: "B,D,F,K,L",
                                   redFrogLocation: "A",
                                   solution: "A-C,K-A,A-G,L-B,C-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 7,
                                   greenFrogsLocations: "A,D,F,I,H",
                                   redFrogLocation: "G",
                                   solution: "A-K,G-A,K-G,H-F,A-K").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 8,
                                   greenFrogsLocations: "A,D,E,F,J",
                                   redFrogLocation: "G",
                                   solution: "G-C,A-G,F-H,C-M,M-G").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 9,
                                   greenFrogsLocations: "A,D,F,I,H,J",
                                   redFrogLocation: "E",
                                   solution: "A-K,H-L,L-F,K-A,A-G,E-I").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Beginner,
                                   id: 10,
                                   greenFrogsLocations: "A,D,F,G,I,M",
                                   redFrogLocation: "B",
                                   solution: "F-H,A-G,I-E,M-C,C-G,B-L").toLevel())
    }
    
    private func initializeIntermediate(){
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 11,
                                   greenFrogsLocations: "A,D,E,I,L",
                                   redFrogLocation: "J",
                                   solution: "L-F,F-B,A-C,C-G,J-D").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 12,
                                   greenFrogsLocations: "A,B,E,F,H,I",
                                   redFrogLocation: "L",
                                   solution: "A-C,H-B,C-A,A-K,K-G,L-B").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 13,
                                   greenFrogsLocations: "A,B,D,I,K,L",
                                   redFrogLocation: "F",
                                   solution: "K-G,A-C,L-B,C-A,A-G,F-H").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 14,
                                   greenFrogsLocations: "A,B,D,F,J",
                                   redFrogLocation: "K",
                                   solution: "A-G,K-A,J-D,B-F,A-K").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 15,
                                   greenFrogsLocations: "A,D,E,G,H,I,L",
                                   redFrogLocation: "J",
                                   solution: "G-C,A-G,J-D,C-M,M-K,K-G,D-J").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 16,
                                   greenFrogsLocations: "B,E,F,G,H,I,J,L",
                                   redFrogLocation: "D",
                                   solution: "G-C,C-M,L-H,M-C,C-A,A-K,K-G,D-J").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 17,
                                   greenFrogsLocations: "A,B,D,E,F,G,H,I,L",
                                   redFrogLocation: "J",
                                   solution: "A-C,G-K,K-A,A-G,E-I,C-M,M-K,K-G,J-D").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 18,
                                   greenFrogsLocations: "A,B,D,E,F,J",
                                   redFrogLocation: "I",
                                   solution: "A-C,F-B,B-H,C-M,M-G,I-E").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 19,
                                   greenFrogsLocations: "A,B,E,F,I,J,L",
                                   redFrogLocation: "D",
                                   solution: "A-C,L-H,H-B,C-A,A-K,K-G,D-J").toLevel())
        
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Intermediate,
                                   id: 20,
                                   greenFrogsLocations: "B,D,F,G,I,J,L",
                                   redFrogLocation: "E",
                                   solution: "G-M,M-K,K-A,B-F,A-K,K-G,E-I").toLevel())
    }
    
    private func initializeAdvanced(){
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 21,
                                   greenFrogsLocations: "A,D,F,G,J,L,M",
                                   redFrogLocation: "I",
                                   solution: "I-E,A-G,J-D,M-K,K-A,A-G,E-I").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 22,
                                   greenFrogsLocations: "A,B,D,E,F,G,J,M",
                                   redFrogLocation: "I",
                                   solution: "A-C,F-H,H-B,C-A,A-G,I-E,M-G,E-I").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 23,
                                   greenFrogsLocations: "A,B,D,E,F,H,I,M",
                                   redFrogLocation: "L",
                                   solution: "A-K,K-G,E-I,M-C,C-A,A-G,L-F,F-H").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 24,
                                   greenFrogsLocations: "A,C,D,E,G,I,J,K,M",
                                   redFrogLocation: "F",
                                   solution: "F-H,A-G,J-D,K-G,D-J,C-G,H-F,M-G,F-H").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 25,
                                   greenFrogsLocations: "A,B,D,E,F,H,I,L",
                                   redFrogLocation: "J",
                                   solution: "A-C,H-B,C-A,A-K,L-F,K-A,A-G,J-D").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 26,
                                   greenFrogsLocations: "A,B,D,E,F,G,I",
                                   redFrogLocation: "J",
                                   solution: "A-C,G-K,K-A,A-G,J-D,C-G,D-J").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 27,
                                   greenFrogsLocations: "A,D,E,F,H,I,K",
                                   redFrogLocation: "B",
                                   solution: "F-L,K-M,M-C,C-G,B-L,A-G,L-B").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 28,
                                   greenFrogsLocations: "A,D,E,F,I,J,K",
                                   redFrogLocation: "G",
                                   solution: "G-C,A-G,F-H,K-G,H-L,L-B,C-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 29,
                                   greenFrogsLocations: "A,B,C,D,E,F,I,K",
                                   redFrogLocation: "J",
                                   solution: "A-G,J-D,K-G,E-I,C-A,A-K,K-G,D-J").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Advanced,
                                   id: 30,
                                   greenFrogsLocations: "C,D,E,F,J,L,M",
                                   redFrogLocation: "A",
                                   solution: "A-K,M-G,D-J,C-G,L-H,H-F,K-A").toLevel())
    }
    
    private func initializeExpert(){
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 31,
                                   greenFrogsLocations: "A,B,D,E,G,J,K,L,M",
                                   redFrogLocation: "F",
                                   solution: "F-H,A-C,C-G,H-F,M-G,D-J,K-M,M-G,F-H").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 32,
                                   greenFrogsLocations: "A,C,D,E,F,H,I,J,K",
                                   redFrogLocation: "G",
                                   solution: "G-M,K-G,D-J,C-G,J-D,A-G,M-C,F-H,C-M").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 33,
                                   greenFrogsLocations: "A,D,F,E,J,L,M",
                                   redFrogLocation: "G",
                                   solution: "A-K,G-A,M-G,E-I,K-G,L-B,A-C").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 34,
                                   greenFrogsLocations: "A,D,E,F,H,I,L,M",
                                   redFrogLocation: "G",
                                   solution: "A-K,G-A,K-G,E-I,M-K,K-G,H-F,A-K").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 35,
                                   greenFrogsLocations: "A,B,D,E,F,G,H,J,L,M",
                                   redFrogLocation: "I",
                                   solution: "A-C,H-B,I-E,C-A,A-G,J-D,M-K,K-A,A-G,E-I").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 36,
                                   greenFrogsLocations: "A,C,D,E,F,H,I,L",
                                   redFrogLocation: "G",
                                   solution: "A-K,K-M,G-K,C-G,D-J,M-G,H-F,K-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 37,
                                   greenFrogsLocations: "A,B,C,D,E,F,I,J,K",
                                   redFrogLocation: "G",
                                   solution: "G-M,A-G,F-H,K-G,B-L,C-G,L-B,M-C,C-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 38,
                                   greenFrogsLocations: "B,D,F,G,H,J,K,M",
                                   redFrogLocation: "A",
                                   solution: "B-L,M-G,D-J,K-M,M-G,A-K,H-F,K-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 39,
                                   greenFrogsLocations: "A,B,C,D,E,F,H,I,K,L",
                                   redFrogLocation: "M",
                                   solution: "K-G,D-J,M-K,C-M,M-G,F-H,A-C,C-G,H-F,K-A").toLevel())
    
        levels.append(LevelDetails(difficulty: GameManager.Difficulty.Expert,
                                   id: 40,
                                   greenFrogsLocations: "A,B,C,D,E,G,I,J,K,L,M",
                                   redFrogLocation: "F",
                                   solution: "F-H,A-G,J-D,K-G,E-I,C-A,A-G,H-F,M-K,K-G,F-H").toLevel())
    }
    
    private class LevelDetails{
        
        var greenFrogsLocations: String
        var redFrogLocation: String
        var solution: String
        var difficulty: GameManager.Difficulty
        var id: Int
        
        init(difficulty: GameManager.Difficulty,
                 id: Int,
                 greenFrogsLocations: String,
                 redFrogLocation: String,
                 solution: String){
            self.greenFrogsLocations = greenFrogsLocations
            self.redFrogLocation = redFrogLocation
            self.solution = solution
            self.difficulty = difficulty
            self.id = id
        }
        
        func toLevel() -> LevelLogic{
            
            var solutionList:[Hop] = [Hop]()
            
            // Creating the solution according to the string given (each step is separated by ','):
            let splitSol: [String] = solution.components(separatedBy: (","))
            for solStep in splitSol{
                solutionList.append(LevelsLoader.hopsMap[solStep]!)
            }
            
            // Creating the green frog locations according to the string given (each frog is separated by ','):
            let splitGreenFrogs : [String] = greenFrogsLocations.components(separatedBy: (","))
            var greenFrogs : [Int] = [Int]()
            
            for i in 0...splitGreenFrogs.count-1{
                greenFrogs.append(LevelsLoader.leavesCordsMap[splitGreenFrogs[i]]!.getCellIndex())
            }
            
            // Creating a level with the details gotten
            return LevelLogic(difficulty: difficulty, id: id,
                              redFrogLocation: LevelsLoader.leavesCordsMap[redFrogLocation]!.getCellIndex(),
                              greenFrogsLocations: greenFrogs,
                              solution: solutionList,
                              recordSeconds: 0,
                              recordMinutes: 0,
                              recordHours: 0,
                              isSolutionViewed: false)
        }
    }
}
