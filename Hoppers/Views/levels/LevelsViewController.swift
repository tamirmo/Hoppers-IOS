//
//  LevelsViewController.swift
//  Hoppers
//
//  Created by Tamir on 14/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import UIKit

class LevelsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: Consts
    
    // The number of sections on the screen at a time
    public static let SECTIONS_ON_SCREEN_PORTRAIT: Int = 3
    public static let SECTIONS_ON_SCREEN_LANDSCAPE: Int = 1
    public static let ITEMS_IN_SECTION: Int = 2
    private static var CELLS_MARGIN:CGFloat = 5
    
    // MARK: Members
    
    private var difficulty: GameManager.Difficulty?
    private var levels: [LevelLogic]?
    
    @IBOutlet weak var levelsCollectionView: UICollectionView!
    
    public func setDifficulty(difficulty: GameManager.Difficulty){
        self.difficulty = difficulty
        levels = GameManager.getInstance().getLevelsByDifficulty(difficulty: self.difficulty!)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // When the screen changes rotation,
        // updating the collection view
        levelsCollectionView.reloadData()
        levelsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reloading cause this migth happen when the user has finished a level and presses back
        levelsCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Getting the number of rows and columns according to the current layout:
        
        var columnsCount = LevelsViewController.ITEMS_IN_SECTION
        var rowsCount = LevelsViewController.SECTIONS_ON_SCREEN_PORTRAIT
        
        // Getting the scren orientation from the app delegate and acting accordingly:
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.IsOrientationLandscape){
            columnsCount = LevelsViewController.ITEMS_IN_SECTION
            rowsCount = LevelsViewController.SECTIONS_ON_SCREEN_LANDSCAPE
        }
        
        // Calculating the size avialable for the cells (substructing the space)
        let collectionViewCellsBoundWidth = (levelsCollectionView.bounds.size.width - CGFloat(columnsCount) * (LevelsViewController.CELLS_MARGIN))
        let collectionViewCellsBoundHeight = (levelsCollectionView.bounds.size.height - CGFloat(rowsCount) * (LevelsViewController.CELLS_MARGIN))
        
        let cellWidth = collectionViewCellsBoundWidth / CGFloat(columnsCount)
        let cellHeight = collectionViewCellsBoundHeight / CGFloat(rowsCount)
        return CGSize(width: Int(cellWidth), height: Int(cellHeight))
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Getting the number of items in sections according to the orientation from the app delegate:
        let itemsInSection: Int = getItemsInSections()
        // Getting the level of the current index (each section has ITEMS_IN_SECTION items)
        let levelIndex: Int = indexPath.section * itemsInSection + indexPath.row
        
        // Moving to the game view:
        let gameController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameController.setLevelNum(levelNum: levels![levelIndex].Id)
        self.navigationController!.pushViewController(gameController, animated: true)
    }

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = levelsCollectionView.dequeueReusableCell(withReuseIdentifier: "LevelCollectionViewCell", for: indexPath) as! LevelCollectionViewCell
        
        // Getting the number of items in sections according to the orientation from the app delegate:
        let itemsInSection: Int = getItemsInSections()

        // Getting the level of the current index (each section has ITEMS_IN_SECTION items)
        let levelId: Int = indexPath.section * itemsInSection + indexPath.row
        let level: LevelLogic = levels![levelId]
        // Setting the cell the level it belongs to
        cell.setLevel(level: level)
        
        cell.updateView()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getNumOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Getting the number of items in sections according to the orientation from the app delegate:
        let itemsInSection: Int = getItemsInSections()
        return itemsInSection
    }
    
    private func getItemsInSections() -> Int{
        // Getting the number of items in sections according to the orientation from the app delegate:
        var itemsInSection: Int = LevelsViewController.ITEMS_IN_SECTION
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.IsOrientationLandscape){
            itemsInSection = LevelsViewController.ITEMS_IN_SECTION
        }
        
        return itemsInSection
    }
 
    private func getNumOfSections() -> Int{
        // Getting the number of items in sections according to the orientation from the app delegate:
        let itemsInSection: Int = getItemsInSections()
        return levels!.count / itemsInSection
    }
}
