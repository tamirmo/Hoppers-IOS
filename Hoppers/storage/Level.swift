//
//  Level.swift
//  Hoppers
//
//  Representing one record of a level from the core data.
//  Created by tamir on 5/29/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import CoreData

class Level: NSManagedObject{
    // MARK: - Consts
    
    public static let TABLE_NAME = "Levels"
    private static let SECONDS_IN_MINUTE = 60
    private static let SECONDS_IN_HOUR = SECONDS_IN_MINUTE * 60
    
    // MARK: - Members
    
    @NSManaged private var id: NSNumber!
    @NSManaged private var difficulty: NSNumber!
    @NSManaged private var high_score_hours: NSNumber!
    @NSManaged private var high_score_minutes: NSNumber!
    @NSManaged private var high_score_seconds: NSNumber!
    @NSManaged private var is_solution_viewed: NSNumber!
    @NSManaged private var red_frog_location: NSNumber!
    @NSManaged private var solution: String!
    @NSManaged private var green_frogs: String!
    
    // MARK: - Properties
    
    var Id: Int {
        return id.intValue
    }
    
    var Difficulty: Int {
        return difficulty.intValue
    }
    
    var HighScoreHours: Int {
        return high_score_hours.intValue
    }
    
    var HighScoreMinutes: Int {
        return high_score_minutes.intValue
    }
    
    var HighScoreSeconds: Int {
        return high_score_seconds.intValue
    }
    
    var IsSolutionViewed: Int {
        return is_solution_viewed.intValue
    }
    
    var RedFrogLocation: Int {
        return red_frog_location.intValue
    }
    
    var GreenFrogs: String {
        return green_frogs
    }
    
    var Solution: String {
        return solution
    }
    
    // MARK: - Ctor
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - Methods
    
    @discardableResult
    func save() -> Bool {
        var isSaved = false
        do {
            try self.managedObjectContext?.save()
            isSaved = true
        } catch {}
        
        return isSaved
    }
    
    func remove() {
        self.managedObjectContext?.delete(self)
    }
}
