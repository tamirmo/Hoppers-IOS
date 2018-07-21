//
//  LevelsDbHelper.swift
//  Hoppers
//
//  Created by tamir on 5/29/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LevelsDbHelper{
    
    // MARK: - Members
    
    private weak var context : NSManagedObjectContext?
    private var levelsQueue : DispatchQueue
    
    // MARK: - Ctor
    
    init(context : NSManagedObjectContext) {
        // Saving context for all CoreData operations
        self.context = context
        
        self.levelsQueue = DispatchQueue(label: "LevelsDbHelper", attributes: DispatchQueue.Attributes.concurrent)
    }
    
    // MARK: - Methods
    
    /**
     This method adds the given level to the DB.
     (high score is set to 0 and solution not viewed
     - Parameter id: The level id.
     - Parameter redFrogLocation: An index for the red frog begining location.
     - Parameter greenFrogs: A string containing all the green frog's locations.
     - Parameter solution: the hops of the solution with separators
     */
    func addLevel(id: Int, difficulty: Int, redFrogLocation: Int, greenFrogs: String, solution: String){
        // Adding the new level :
        
        let entity = NSEntityDescription.entity(forEntityName: Level.TABLE_NAME, in: context!)
        let level: Level? = Level(entity: entity!, insertInto: context)
        level!.setValue(id, forKey: "id")
        level!.setValue(redFrogLocation, forKey: "red_frog_location")
        level!.setValue(difficulty, forKey: "difficulty")
        level!.setValue(greenFrogs, forKey: "green_frogs")
        // When adding a level the solution is not yet viewed
        // and the high score does not exist
        level!.setValue(false, forKey: "is_solution_viewed")
        level!.setValue(0, forKey: "high_score_hours")
        level!.setValue(0, forKey: "high_score_minutes")
        level!.setValue(0, forKey: "high_score_seconds")
        level!.setValue(solution, forKey: "solution")
        
        level?.save()
    }
    
    /**
     This method pulls all the levels in the game from the DB.
     (pulling is done asyncronisly, delegate is informed when done)
     - Parameter levelsDelegate: A delegate to notify when loading is finished.
     */
    func getLevels(levelsDelegate: LevelsDelegate){
        levelsQueue.async {[weak self, weak levelsDelegate] in
            if self != nil {
                var levels: [Level]? = nil
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: Level.TABLE_NAME)
                request.returnsObjectsAsFaults = false
                // Sorting by id to get an ordered array
                request.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
                do {
                    let result = try self!.context?.fetch(request)
                    levels = result as? [Level]
                } catch {
                    print("@@@@@@@@@@@@ Failed")
                }
                
                // Alerting the delegate of the operation ended
                levelsDelegate?.levelsPulled(levels: levels)
            }
        }
    }
    
    func updateSolutionViewedById(levelId: Int){
        levelsQueue.async {[weak self] in
            
            var lowestScore: Level? = nil
            let request = self!.getLevelFetchReq(levelId: levelId)
            
            // Taking only one level
            request.fetchLimit = 1
            
            do {
                // Executing the request and taking the first (and only) level
                let result = try self!.context?.fetch(request)
                lowestScore = (result as? [Level])?.first
                // Updating the is_solution_viewed to true and saving:
                lowestScore?.setValue(true, forKey: "is_solution_viewed")
                lowestScore?.save()
            } catch {
                print("@@@@@@@@@@@@ Failed")
            }
        }
    }
    
    /**
     This method updates the given level id with the given record.
     - Parameter levelId: The id of the level to update.
     - Parameter hours: The hours of the new record.
     - Parameter minutes: The minutes of the new record.
     - Parameter seconds: The seconds of the new record.
     */
    func updateHighScoreById(levelId: Int,
                             hours: Int,
                             minutes: Int,
                             seconds: Int){
        levelsQueue.async {[weak self] in
            
            var lowestScore: Level? = nil
            let request = self!.getLevelFetchReq(levelId: levelId)
            
            // Taking only one level
            request.fetchLimit = 1
            
            do {
                // Executing the request and taking the first (and only) level
                let result = try self!.context?.fetch(request)
                lowestScore = (result as? [Level])?.first
                // Updating the score and saving:
                lowestScore?.setValue(hours, forKey: "high_score_hours")
                lowestScore?.setValue(minutes, forKey: "high_score_minutes")
                lowestScore?.setValue(seconds, forKey: "high_score_seconds")
                lowestScore?.save()
            } catch {
                print("@@@@@@@@@@@@ Failed")
            }
        }
    }
    
    /**
     This method creates a fetch request for the levels core data base with the given difficulty.
     - Parameter levelId: The id of the level to get petch.
     - returns: A fetch request for the levels core data base with the given id
     */
    private func getLevelFetchReq(levelId: Int) -> NSFetchRequest<NSFetchRequestResult>{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Level.TABLE_NAME)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == \(levelId)")
        return request
    }
}
