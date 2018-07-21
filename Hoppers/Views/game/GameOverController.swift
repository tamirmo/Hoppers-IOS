//
//  GameOverController.swift
//  Hoppers
//
//  Created by Tamir on 21/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import UIKit

class GameOverController : UIViewController {
    // MARK: Members
    
    private var nextLevelId: Int?
    // The time played the finished level
    private var finishedTime: String?
    
    @IBOutlet weak var finishedTimeLabel: UILabel!
    @IBOutlet weak var nextLevelImage: UIImageView!
    @IBOutlet weak var nextLevelLabel: UILabel!
    
    func setNextLevelId(_ nextLevel: Int){
        self.nextLevelId = nextLevel
    }
    
    func setFinishedTime(_ finishedTime: String){
        self.finishedTime = finishedTime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextLevelLabel.text = "Try level " + String( nextLevelId!)
        finishedTimeLabel.text = "Finished time: " + String( finishedTime!)
        
        // Setting click event for the next level button:
        let nextLevelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextLevelTapped(tapGestureRecognizer:)))
        nextLevelImage.addGestureRecognizer(nextLevelGestureRecognizer)
        nextLevelImage.isUserInteractionEnabled = true
        
        // If there is no next level
        if nextLevelId! > GameManager.getInstance().MaxLevelId {
            // Hiding the the next level button and label
            nextLevelLabel.isHidden = true
            nextLevelImage.isHidden = true
        }
        
        // Registering to the back button press
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(GameOverController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton

    }
    
    @objc func nextLevelTapped(tapGestureRecognizer: UITapGestureRecognizer){
        // Getting the view controllers in the stack
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        
        // Getting the game controller and setting the level:
        let gameController = viewControllers[viewControllers.count - 2] as! GameViewController
        gameController.setLevelNum(levelNum: nextLevelId!)
        gameController.gameInitialize()
        
        // Moving to the game controller
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the levels view controller and not the game one
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}
