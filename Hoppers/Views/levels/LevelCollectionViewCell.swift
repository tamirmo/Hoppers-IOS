//
//  LevelCollectionViewCell.swift
//  Hoppers
//
//  Created by Tamir on 14/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import UIKit

class LevelCollectionViewCell: UICollectionViewCell {
    // MARK: Members
    
    @IBOutlet weak var solutionViewImage: UIImageView!
    @IBOutlet weak var leafImage: UIImageView!
    @IBOutlet weak var levelIdLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var frogImage: UIImageView!
    
    private var level: LevelLogic?
    
    func setLevel(level: LevelLogic){
        self.level = level
    }
    
    func updateView(){
        levelIdLabel.text = String(level!.Id)
        
        if(level!.IsSolutionViewed){
            solutionViewImage.isHidden = false
        }else{
            solutionViewImage.isHidden = true
        }
        
        if(level!.IsSolved){
            recordLabel.isHidden = false
            recordLabel.text = "Record: " + level!.string
            frogImage.image = #imageLiteral(resourceName: "green_frog_levels_winner")
        }else{
            recordLabel.isHidden = true
            frogImage.image = #imageLiteral(resourceName: "green_frog")
        }
        
        var levelBackground: UIColor
        
        switch level!.Difficulty{
        case .Beginner:
            levelBackground = beginnersColor
            break
        case .Intermediate:
            levelBackground = intermediateColor
            break
        case .Advanced:
            levelBackground = advancedColor
            break
        case .Expert:
            levelBackground = expertColor
            break
        }
        
        backgroundColor = levelBackground
        layer.borderColor = UIColor.white.cgColor
    }
}
