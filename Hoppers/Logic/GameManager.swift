//
//  GameManager.swift
//  Hoppers
//
//  Holding the swamp, handling turns, alerting of a game won and managing all game operations.
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import CoreData

class GameManager : LevelsLoadedDelegate{
    
    // MARK: - Singleton
    
    private static var shared: GameManager? = nil
    
    class func getInstance() -> GameManager {
        if shared == nil {
            shared = GameManager()
        }
        return shared!
    }
    
    // MARK: - Enums
    
    enum Difficulty: Int {
        case Beginner
        case Intermediate
        case Advanced
        case Expert
        
        static let allValues = [Beginner, Intermediate, Advanced, Expert]
        
        init?(id : Int) {
            switch id {
            case 0:
                self = .Beginner
            case 1:
                self = .Intermediate
            case 2:
                self = .Advanced
            case 3:
                self = .Expert
            default:
                return nil
            }
        }
        
        var string: String {
            return String(describing: self)
        }
    }
    
    // MARK: - Members
    
    private var swamp: Swamp
    private var currLevel: LevelLogic?
    private var hops: Stack<Hop>
    private var levels: [LevelLogic]
    
    // Time played:
    private var seconds: Int
    private var minutes: Int
    private var hours: Int
    
    private var timeTimer: Timer? = nil
    public weak var gameDurationChangedListener: GameDurationChangedDelegate?
    public weak var managerInitiatedDelegate: ManagerInitiatedDelegate?
    private var levelsDbHelper: LevelsDbHelper? = nil
    private var loader: LevelsLoader?
    
    // An index indicating the current solution step
    private var solutionIndex: Int
    
    // MARK: - Properties
    
    var Levels: [LevelLogic] {
        return self.levels
    }
    
    var MaxLevelId: Int {
        return levels[levels.count - 1].Id
    }
    
    var GameDuration: String{
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    public func pauseGame(){
        stopTimer()
    }
    
    public func resumeGame(){
        startTimer()
    }
    
    init(){
        swamp = Swamp()
        hops = Stack<Hop>()
        levels = [LevelLogic]()
        currLevel = nil
        seconds = 0
        minutes = 0
        hours = 0
        solutionIndex = 0
    }
    
    // MARK: - Methods
    
    public func initializeManager(context : NSManagedObjectContext){
        levelsDbHelper = LevelsDbHelper(context: context)
    
        swamp = Swamp()
        hops = Stack<Hop>()
    
        // Pulling all levels from the DB (registering for the loading finished event
        loader = LevelsLoader(levelsDbHelper: levelsDbHelper!)
        loader!.levelsLoadedDelegate = self
        loader!.loadLevels()
    }
    
    public func startGame(levelId: Int){
        currLevel = getLevelById(id: levelId)
        seconds = 0
        minutes = 0
        hours = 0
        hops.clear()
    
        swamp.setLevel(level: currLevel!)
    
        startTimer()
    }
    
    /**
     Returning the level with the given id from the list of levels loaded in the manager.
     - Parameter id: The id to search the level for
     - returns: The Level object with the id given
     */
    private func getLevelById(id: Int) -> LevelLogic?{
        var level: LevelLogic? = nil
        for currLevel in levels{
            if(currLevel.Id == id){
                level = currLevel
                break
            }
        }
        return level
    }
    
    /**
     This method prepares the start of showing the solution for the user
     */
    public func startShowSolution(){
        swamp.setLevel(level: currLevel!)
        solutionIndex = 0

        levelsDbHelper!.updateSolutionViewedById(levelId: currLevel!.Id)
        
        // Updating the local level
        currLevel!.IsSolutionViewed = true
    }
    
    public func nextSolutionStep() -> Hop?{
        // Default indicating the solution is over
        var nextHop: Hop? = nil
    
        // Checking if there is a next solution step
        if(solutionIndex < currLevel!.Solution.count) {
            nextHop = currLevel!.Solution[solutionIndex]
            swamp.makeHop(hop: nextHop!)
            
            // Incresing the index for next time
            solutionIndex += 1
        }
    
        return nextHop
    }
    
    public func prevSolutionStep() -> Hop?{
        // Default indicating there is no previous solution
        var prevHop: Hop? = nil
    
        // Going back to the last step
        solutionIndex -= 1
        
        if solutionIndex >= 0 {
            prevHop = currLevel!.Solution[solutionIndex]
            swamp.revertHop(hop: prevHop!)
        }else{
            solutionIndex = 0
        }
    
        return prevHop
    }
    
    public func getLeaf(index: Int) -> Leaf?{
        return swamp.getLeaf(coordinate: LeafCoord(cellIndex: index))
    }
    
    public func getLeaf(row: Int, column: Int) -> Leaf?{
        return swamp.getLeaf(coordinate: LeafCoord(row: row, column: column))
    }
    
    public func setSelectedLeaf(row: Int, column: Int){
        swamp.selectLeaf(coordinate: LeafCoord(row: row, column: column))
    }
    
    private func startTimer(){
        // Starting only if not already running
        if timeTimer == nil {
            // Staring a timer to count the time
            timeTimer = Timer.scheduledTimer(timeInterval: 1,
                                             target: self,
                                             selector: #selector(timeTimerElapsed),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    private func stopTimer(){
        timeTimer?.invalidate()
        timeTimer = nil
    }
    
    @objc func timeTimerElapsed() ->Void {
        seconds += 1
        if(seconds > 60){
            seconds = 0
            minutes += 1
            if(minutes > 60){
                minutes = 0
                hours += 1
            }
        }
    
        if gameDurationChangedListener != nil{
            gameDurationChangedListener!.gameDurationChanged(duration: GameDuration)
        }
    }
    
    /**
     Performing a hop of the frog from the selected leaf to the given
     (called when the user chooses to hop)
     - Parameter destinationLeafCord: The coordinate of the leaf to hop to
     - returns: The coordinate of the from eaten
     */
    public func hop(destinationLeafCord: LeafCoord) -> Turn{
        var hop: Hop
        var turnResult: Turn
        let destLeaf: Leaf? = swamp.getLeaf(coordinate: destinationLeafCord)

        if destLeaf != nil && destLeaf!.IsValidHop {
    
            // Searching for the frog eaten:
            
            let eatenFrogCord = getEatenFrogLeaf(originalLeaf: swamp.SelectedFrogCord!, destinationLeafCord: destinationLeafCord)
    
            hop = Hop(frogOriginalLeaf: swamp.SelectedFrogCord!, frogHoppedLeaf: destinationLeafCord, eatenFrogLeaf: eatenFrogCord!)
    
            // Removing the eaten frog from the game and moving the hopped frog
            swamp.makeHop(hop: hop)
    
            turnResult = Turn(result: Turn.TurnResult.Hop, hop: hop)
            hops.push(hop)
            
            if(swamp.isOnlyRedFrog()){
                turnResult = Turn(result: Turn.TurnResult.GameWon, hop: hop)
                
                // Game is over, stopping timer
                stopTimer()
                
                if(isGameDurationRecord()){
                    // Saving the record
                    levelsDbHelper!.updateHighScoreById(levelId: currLevel!.Id, hours: hours, minutes: minutes, seconds: seconds)
                    
                    // Updating the local level:
                    currLevel!.RecordHours  = hours
                    currLevel!.RecordMinutes = minutes
                    currLevel!.RecordSeconds = seconds
                }
            }
        }
        else {
            turnResult = Turn(result: Turn.TurnResult.InvalidHop, hop: nil)
        }
    
        return turnResult
    }
    
    /**
     Calculating the eaten frog in the hop that a frog that it's coordinates are given to the given destFrogIndex.
     - Parameter originalLeaf: The original coordinates of the frog hopping
     - Parameter destinationLeafCord: The index of the leaf hopping to
     - returns: LeafCoordinate The coordinates of the eaten frog
     */
    private func getEatenFrogLeaf(originalLeaf: LeafCoord, destinationLeafCord: LeafCoord) -> LeafCoord?{
        let originalFrogRow: Int = originalLeaf.Row
        let originalFrogCol: Int = originalLeaf.Column
        let destFrogIndex: Int = LeafCoord.getCellIndex(row: destinationLeafCord.Row, col: destinationLeafCord.Column)
    
        var eatenFrog: LeafCoord?
    
        // Tf the frog is a row with 3 columns
        if(originalFrogRow % 2 == 0){
            eatenFrog = getEatenFrogLeafEvenRow(destFrogIndex: destFrogIndex, originalFrogRow: originalFrogRow, originalFrogCol: originalFrogCol)
        }else{
            eatenFrog = getEatenFrogLeafOddRow(destFrogIndex: destFrogIndex, originalFrogRow: originalFrogRow, originalFrogCol: originalFrogCol)
        }
        
        return eatenFrog
    }
    
    /**
     Calculating the eaten frog in the hop that a frog that it's coordinates are given to the given destFrogIndex.
     (This method is for a leaf that has 3 frogs in it's row [even row number])
     - Parameter destFrogIndex: The index of the leaf hopping to
     - Parameter originalFrogRow: The original row of the frog hopping
     - Parameter originalFrogCol: The original column of the frog hopping
     - returns: LeafCoordinate The coordinates of the eaten frog
     */
    private func getEatenFrogLeafEvenRow(destFrogIndex: Int,
                                         originalFrogRow: Int,
                                         originalFrogCol: Int)-> LeafCoord?{
        var eatenFrog: LeafCoord? = nil
    
        // Handling the "straight" hop
        // (not available for frogs in a row with two leaves):
    
        // Hop down
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow + 4, col: originalFrogCol)){
            eatenFrog = LeafCoord(row: originalFrogRow + 2, column: originalFrogCol)
        }
    
        // Hop up
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow - 4, col: originalFrogCol)){
            eatenFrog = LeafCoord(row: originalFrogRow - 2, column: originalFrogCol)
        }
    
        // Hop right
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow, col: originalFrogCol + 2)){
            eatenFrog = LeafCoord(row: originalFrogRow, column: originalFrogCol + 1)
        }
    
        // Hop left
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow, col: originalFrogCol - 2)){
            eatenFrog = LeafCoord(row: originalFrogRow, column: originalFrogCol - 1)
        }
    
        // Handling the "diagonal" hop:
    
        // Diagonal down left
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow + 2, col: originalFrogCol - 1)){
            eatenFrog = LeafCoord(row: originalFrogRow + 1, column: originalFrogCol - 1)
        }
    
        // Diagonal down right
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow + 2, col: originalFrogCol + 1)){
            eatenFrog = LeafCoord(row: originalFrogRow + 1, column: originalFrogCol)
        }
    
        // Diagonal up left
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow - 2, col: originalFrogCol - 1)){
            eatenFrog = LeafCoord(row: originalFrogRow - 1, column: originalFrogCol - 1)
        }
    
        // Diagonal up right
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow - 2, col: originalFrogCol + 1)){
            eatenFrog = LeafCoord(row: originalFrogRow - 1, column: originalFrogCol)
        }
    
        return eatenFrog
    }
    
    /**
     Calculating the eaten frog in the hop that a frog that it's coordinates are given to the given destFrogIndex.
     (This method is for a leaf that has 2 frogs in it's row [odd row number])
     - Parameter destFrogIndex: The index of the leaf hopping to
     - Parameter originalFrogRow: The original row of the frog hopping
     - Parameter originalFrogCol: The original column of the frog hopping
     - returns: LeafCoordinate The coordinates of the eaten frog
     */
    private func getEatenFrogLeafOddRow(destFrogIndex: Int,
                                    originalFrogRow: Int,
                                    originalFrogCol: Int) -> LeafCoord?{
        var eatenFrog: LeafCoord? = nil
    
        // Handling the "diagonal" hop:
    
        // Diagonal down left
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow + 2, col: originalFrogCol - 1)){
            eatenFrog = LeafCoord(row: originalFrogRow + 1, column: originalFrogCol)
        }
    
        // Diagonal down right
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow + 2, col: originalFrogCol + 1)){
            eatenFrog = LeafCoord(row: originalFrogRow + 1, column: originalFrogCol + 1)
        }
    
        // Diagonal up left
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow - 2, col: originalFrogCol - 1)){
            eatenFrog = LeafCoord(row: originalFrogRow - 1, column: originalFrogCol)
        }
    
        // Diagonal up right
        if(destFrogIndex == LeafCoord.getCellIndex(row: originalFrogRow - 2, col: originalFrogCol + 1)){
            eatenFrog = LeafCoord(row: originalFrogRow - 1, column: originalFrogCol + 1)
        }
    
        return eatenFrog
    }
    
    private func isGameDurationRecord() -> Bool{
    var isRecord: Bool = false
    
        if(!currLevel!.IsSolved ||
            (hours < currLevel!.RecordHours ||
            // If the hours are the same, checking minutes
            (hours == currLevel!.RecordHours &&
            (minutes < currLevel!.RecordMinutes ||
            // If minutes are the same, checking the seconds
            (minutes == currLevel!.RecordMinutes && seconds < currLevel!.RecordSeconds)) ))){
            isRecord = true
        }
    
        return isRecord
        
    }
    
    /**
     Returning the swamp to the state before the last hop
     - returns: True if there was a hop to return before, False if not
     */
    public func undoLastStep() -> Bool{
        var wasHoppedBack: Bool = false
    
        if(hops.items.count > 0){
            let lastHop: Hop = hops.pop()
    
            // Returning the eaten frog to the game
            swamp.getLeaf(coordinate: lastHop.EatenFrogLeaf)!.LeafType = .GreenFrog
    
            // Returning the eaten frog to the game
            let eatingFrog: Leaf.LeafType = swamp.getLeaf(coordinate: lastHop.FrogHoppedLeaf)!.LeafType
            // Returning it to the original place:
            swamp.getLeaf(coordinate: lastHop.FrogOriginalLeaf)!.LeafType = eatingFrog
            swamp.getLeaf(coordinate: lastHop.FrogHoppedLeaf)!.LeafType = .Empty
    
            // The last selected is not relevant anymore
            swamp.clearSelectedLeaf()
    
            wasHoppedBack = true
        }
    
        return wasHoppedBack
    }
    
    /**
     Creates a list of all levels in the given difficulty
     - Parameter difficulty: The difficulty to get levels of
     - returns: A list of levels in the given difficulty
     */
    public func getLevelsByDifficulty(difficulty: Difficulty) -> [LevelLogic]{
    
        var difficultyLevels: [LevelLogic] = [LevelLogic]()
        for level in levels{
            if level.Difficulty == difficulty{
                difficultyLevels.append(level)
            }
        }
    
        return difficultyLevels
    }
    
    public func getRandomLevel(difficulty: Difficulty) -> Int{
        var chosenDifficultyLevels: [LevelLogic] = getLevelsByDifficulty(difficulty: difficulty)
    
        // Choosing a random level:
    
        let levelListIndex: Int = random(chosenDifficultyLevels.count)
        let chosenLevel: LevelLogic = chosenDifficultyLevels[levelListIndex]
    
        return chosenLevel.Id
    }
    
    private func random(_ n:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    // MARK: - LevelsLoadedDelegate
    
    // Called when the levels loader has finished loading levels from the database
    func levelsLoaded(levels: [LevelLogic]) {
        // Updating the local levels
        self.levels = levels
        
        // Alerting the listener the manager has finished the initiating proccess
        // (the last step is the levels loading)
        managerInitiatedDelegate?.managerInitiated()
    }
    
}
