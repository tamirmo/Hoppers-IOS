//
//  GameViewController.swift
//  Hoppers
//
//  Created by Tamir on 15/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class GameViewController: UIViewController, GameDurationChangedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: Consts
    
    private static var CELLS_MARGIN:CGFloat = 10
    private static var BOARD_COLUMNS:CGFloat = 3
    private static var HOP_ANIMATION_DURATION:Double = 0.6
    private static var HOP_SOUND_FILE_NAME:String = "hop"
    
    // MARK: Members
    
    private var levelNum: Int?
    private var isGameOver: Bool = false
    private var lastFrogEatenCoord: LeafCoord?
    private var player: AVAudioPlayer?
    
    @IBOutlet weak var undoImage: UIImageView!
    @IBOutlet weak var levelIdLabel: UILabel!
    @IBOutlet weak var board: UICollectionView!
    @IBOutlet weak var timePlayedLabel: UILabel!
    @IBOutlet weak var viewSolutionButton: UIButton!
    @IBOutlet weak var solutionNavigationView: UIView!
    @IBOutlet weak var nextImage: UIImageView!
    @IBOutlet weak var previousImage: UIImageView!
    // A frog used for animation of hops
    // (avoiding creating a new frog each time)
    @IBOutlet weak var animationFrog: UIImageView!
    
    func setLevelNum(levelNum: Int){
        self.levelNum = levelNum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting click event for the undo button:
        let undoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(undoClick(tapGestureRecognizer:)))
        undoImage.addGestureRecognizer(undoGestureRecognizer)
        undoImage.isUserInteractionEnabled = true
        
        // Setting click event for the view solution button:
        let viewSolutionGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewSolutionClick(tapGestureRecognizer:)))
        viewSolutionButton.addGestureRecognizer(viewSolutionGestureRecognizer)
        viewSolutionButton.isUserInteractionEnabled = true
        
        // Setting click event for the next button:
        let nextGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextSolutionClick(tapGestureRecognizer:)))
        nextImage.addGestureRecognizer(nextGestureRecognizer)
        nextImage.isUserInteractionEnabled = true
        
        // Setting click event for the previous button:
        let previousGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previousSolutionClick(tapGestureRecognizer:)))
        previousImage.addGestureRecognizer(previousGestureRecognizer)
        previousImage.isUserInteractionEnabled = true
        
        gameInitialize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // When the screen changes rotation,
        // updating the collection view
        board.reloadData()
        board.collectionViewLayout.invalidateLayout()
    }
    
    func playMp3Sound(soundFileName: String){
        // Taken from: https://stackoverflow.com/questions/32036146/how-to-play-a-sound-using-swift
        
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if #available(iOS 11.0, *) {
                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            }
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func gameInitialize(){
        // Setting the level
        levelIdLabel.text = String(describing: levelNum!)
        // Initializing the members:
        isGameOver = false
        lastFrogEatenCoord = nil
        
        // Starting the game with the level selected, registering to the duration changed delegate
        GameManager.getInstance().gameDurationChangedListener = self
        GameManager.getInstance().startGame(levelId: levelNum!)
        
        // At first not showing next and previous buttons
        showViewSolutionLayout()
        
        // Refreshing the board
        updateBoard()
    }
    
    @objc func undoClick(tapGestureRecognizer: UITapGestureRecognizer){
        if GameManager.getInstance().undoLastStep() {
            // Refreshing view
            updateBoard()
        }else{
            showToast(message: "No previous steps")
        }
    }
    
    @objc func viewSolutionClick(tapGestureRecognizer: UITapGestureRecognizer){
        GameManager.getInstance().startShowSolution()
        // No need to display time anymore
        timePlayedLabel.isHidden = true
        // When viewing solution,
        // undo button should not be active
        undoImage.isHidden = true
        
        showSolutionNavigationLayout()
        
        // Refreshing view cause we are back to the beginning
        updateBoard()
    }
    
    @objc func nextSolutionClick(tapGestureRecognizer: UITapGestureRecognizer){
        let hop: Hop? = GameManager.getInstance().nextSolutionStep()
        
        // If there was a step
        if (hop != nil) {
            // Refreshing view and playing a hop sound
            updateHop(hop!)
            // Play sound
            playMp3Sound(soundFileName: GameViewController.HOP_SOUND_FILE_NAME)
        } else {
            // Alerting the user the solution is over
            showToast(message: "Solution is over")
        }
    }
    
    @objc func previousSolutionClick(tapGestureRecognizer: UITapGestureRecognizer){
        let hop: Hop? = GameManager.getInstance().prevSolutionStep()
        
        // Refreshing view
        updateBoard()
        
        if (hop == nil) {
            // Alerting the user the solution is already at the beginning
            showToast(message: "No previous step")
        }
    }
    
    private func showViewSolutionLayout(){
        viewSolutionButton.isHidden = false
        solutionNavigationView.isHidden = true
    }
    
    private func showSolutionNavigationLayout(){
        viewSolutionButton.isHidden = true
        solutionNavigationView.isHidden = false
    }
    
    /**
     Updating the view of each leaf in the board
     */
    func updateBoard(){
        board.reloadData()
    }
    
    /**
     Refreshing the board after a hop
     - Parameter hop: The hop that just happened
     */
    func updateHop(_ hop: Hop){
        
        // Getting the hopping frog's type
        let originalLeafType: Leaf.LeafType =
            GameManager.getInstance().getLeaf(index: hop.FrogHoppedLeaf.getCellIndex())!.LeafType
        
        // Updating the animation frog's image accordingly:
        if originalLeafType == .RedFrog {
            animationFrog.image = #imageLiteral(resourceName: "red_frog_board")
        }else{
            animationFrog.image = #imageLiteral(resourceName: "green_frog_board")
        }
        
        let boardX: CGFloat = self.board.frame.origin.x
        let boardY: CGFloat = self.board.frame.origin.y
        
        // Getting the frogs cells:
        let origLeaf = self.board.cellForItem(at: IndexPath(row:hop.FrogOriginalLeaf.Column, section:hop.FrogOriginalLeaf.Row)) as! LeafCollectionViewCell
        let destLeaf = self.board.cellForItem(at: IndexPath(row:hop.FrogHoppedLeaf.Column, section:hop.FrogHoppedLeaf.Row)) as! LeafCollectionViewCell

        // Saving the coordination of the eaten frog to animate in the next collection view refresh
        self.lastFrogEatenCoord = hop.EatenFrogLeaf
        
        // Hiding the frog in the original leaf (he is now about to hop)
        origLeaf.hideFrog()
        animationFrog.isHidden = false
        
        // Calculating the absolute location of the frog hopping:
        let hoppingFrogAbsX:CGFloat = boardX + origLeaf.frame.origin.x + origLeaf.getFrogFrame().origin.x
        let hoppingFrogAbsY:CGFloat = boardY + origLeaf.frame.origin.y + origLeaf.getFrogFrame().origin.y
        
        // Placing the animation frog in the location of the hopping one:
        animationFrog.frame = CGRect(x: hoppingFrogAbsX,
                                 y: hoppingFrogAbsY,
                                 width: origLeaf.getFrogFrame().width,
                                 height: origLeaf.getFrogFrame().height)
        
        // Starting the hopping animtaion
        UIView.animate(withDuration: GameViewController.HOP_ANIMATION_DURATION, delay: 0,
                       options: UIViewAnimationOptions.curveLinear,
                                   animations: { [weak destLeaf, weak self] in
                                        if self != nil && destLeaf != nil{
                                            // Placing the frog in the location of the destination leaf:
                                            
                                            let destFrogAbsX:CGFloat = boardX + (destLeaf!.frame.origin.x) + destLeaf!.getFrogFrame().origin.x
                                            let destFrogAbsY:CGFloat = boardY + (destLeaf!.frame.origin.y) + destLeaf!.getFrogFrame().origin.y
                                            
                                            self!.animationFrog.frame.origin.x = destFrogAbsX
                                            self!.animationFrog.frame.origin.y = destFrogAbsY
                                        }
                                    },
                                   completion: { [weak self] (finished: Bool) -> Void in
                                    
                                        // After finishing,
                                        // Updating the board and hiding the frog of the animation
                                        self?.animationFrog.isHidden = true
                                        self?.updateBoard()
                                
                                        // If this was the last animation and the game has won:
                                        if self != nil && self!.isGameOver {
                                            // Play winning sound
                                            self?.playMp3Sound(soundFileName: "winning")
                                            
                                            // Moving to the game over view:
                                            let gameOverController = self!.storyboard?.instantiateViewController(withIdentifier: "GameOverController") as! GameOverController
                                            gameOverController.setNextLevelId(self!.levelNum! + 1)
                                            gameOverController.setFinishedTime(GameManager.getInstance().GameDuration)
                                            self!.navigationController!.pushViewController(gameOverController, animated: true)
                                        }
                                    })
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Getting the number of rows and columns according to the current layout:
        let columnsCount = GameViewController.BOARD_COLUMNS
        let rowsCount = Swamp.NUM_OF_ROWS
        
        // Calculating the size avialable for the cells (substructing the space)
        let collectionViewCellsBoundWidth = (board.bounds.size.width - CGFloat(columnsCount) * (GameViewController.CELLS_MARGIN))
        let collectionViewCellsBoundHeight = (board.bounds.size.height - CGFloat(rowsCount) * (GameViewController.CELLS_MARGIN))
        
        let cellWidth = collectionViewCellsBoundWidth / CGFloat(columnsCount)
        let cellHeight = collectionViewCellsBoundHeight / CGFloat(rowsCount)
        return CGSize(width: Int(cellWidth), height: Int(cellHeight))
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if GameManager.getInstance().getLeaf(row: indexPath.section, column: indexPath.row )!.IsValidHop {
            let turnResult: Turn = GameManager.getInstance().hop(destinationLeafCord: LeafCoord(row: indexPath.section, column: indexPath.row))
            if(turnResult.Result == .GameWon){
                // Indicating the game has won
                // (waiting until hop animation is over to move to game over controller)
                isGameOver = true
                
                // Play hop sound
                playMp3Sound(soundFileName: GameViewController.HOP_SOUND_FILE_NAME)
                
                // Refreshing view
                updateHop(turnResult.Hop!)
            }else if(turnResult.Result == .InvalidHop){
                showToast(message: "Invalid Hop!")
            }else if(turnResult.Result == .Hop){
                // Refreshing view
                updateHop(turnResult.Hop!)
                
                // Play hop sound
                playMp3Sound(soundFileName: GameViewController.HOP_SOUND_FILE_NAME)
            }
        }else{
            // Setting the clicked leaf as selected and refreshing view
            GameManager.getInstance().setSelectedLeaf(row: indexPath.section, column: indexPath.row)
            
            // Update the hop
            updateBoard()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = board.dequeueReusableCell(withReuseIdentifier: "LeafCollectionViewCell", for: indexPath) as! LeafCollectionViewCell
        cell.setIndexPath(indexPath: indexPath)
        
        // Checking if the leaf is the last eaten
        if lastFrogEatenCoord?.Column == indexPath.row && lastFrogEatenCoord?.Row == indexPath.section {
            // Indicating we want to animate the visibility change
            cell.setFrogEaten(true)
            // No need to animate the frog next refresh
            lastFrogEatenCoord = nil
        }else{
            // No need to animate the visibility change
            cell.setFrogEaten(false)
        }
        
        cell.update()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Swamp.NUM_OF_ROWS
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfItems: Int
        
        // Getting the number of items in sections according to the row number (even or odd):
        if section % 2 == 0 {
            numOfItems = LeafCoord.EVEN_ROW_FROGS
        }else{
            numOfItems = LeafCoord.ODD_ROW_FROGS
        }
        
        return numOfItems
    }
    
    // MARK: GameDurationChangedDelegate
    
    func gameDurationChanged(duration: String) {
        DispatchQueue.main.async { [weak self] in
            self?.timePlayedLabel.text = "Time playing: " + duration
        }
    }
}
