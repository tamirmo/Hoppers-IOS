//
//  DifficultyViewController.swift
//  Hoppers
//
//  A view controller for choosing a difficulty after clicking play on the home screen.
//  Created by Tamir on 13/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {
    // MARK: Members
    
    @IBOutlet weak var beginnersRow: UIControl!
    @IBOutlet weak var itemediateRow: UIControl!
    @IBOutlet weak var advancedRow: UIControl!
    @IBOutlet weak var expertRow: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the color of the frame for the rows:
        beginnersRow.layer.borderColor = UIColor.white.cgColor
        itemediateRow.layer.borderColor = UIColor.white.cgColor
        advancedRow.layer.borderColor = UIColor.white.cgColor
        expertRow.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func beginnersClick(_ sender: Any) {
        moveToLevelsViewController(difficulty: .Beginner)
    }
    @IBAction func intermediateClick(_ sender: Any) {
        moveToLevelsViewController(difficulty: .Intermediate)
    }
    @IBAction func advancedClick(_ sender: Any) {
        moveToLevelsViewController(difficulty: .Advanced)
    }
    @IBAction func expertClick(_ sender: Any) {
        moveToLevelsViewController(difficulty: .Expert)
    }
    
    private func moveToLevelsViewController(difficulty: GameManager.Difficulty){
        // Moving to the levels view:
        let levelsController = self.storyboard?.instantiateViewController(withIdentifier: "LevelsViewController") as! LevelsViewController
        levelsController.setDifficulty(difficulty: difficulty)
        self.navigationController!.pushViewController(levelsController, animated: true)

    }
}
