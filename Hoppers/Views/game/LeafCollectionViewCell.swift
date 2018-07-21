//
//  LeafCollectionViewCell.swift
//  Hoppers
//
//  Created by Tamir on 16/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

import UIKit

class LeafCollectionViewCell: UICollectionViewCell {
    
    private static let FADE_OUT_ANIM_DURATION: Double = 0.2
    
    @IBOutlet weak var frogImage: UIImageView!
    @IBOutlet weak var leafImage: UIImageView!
    
    private var indexPath: IndexPath?
    
    // Indicating if the frog was just eaten
    private var isFrogEaten: Bool = false
    
    func getFrogFrame() -> CGRect {
        return frogImage.frame
    }
    
    /**
     * Called in a case when the frog in this leaf has been eaten
     * (to display an animation)
     */
    func setFrogEaten(_ isFrogEaten: Bool){
        self.isFrogEaten = isFrogEaten
    }
    
    func setIndexPath(indexPath: IndexPath){
        self.indexPath = indexPath
    }
    
    func hideFrog(){
        frogImage.isHidden = true
    }
    
    func update(){

        // Setting the odd rows to the right (moving the x position):
        if indexPath!.section%2 == 1 {
            frame = CGRect(x: frame.origin.x + frame.width/2, y: frame.origin.y, width: frame.width, height: frame.height)
        }
        
        let leaf: Leaf = GameManager.getInstance().getLeaf(row: indexPath!.section, column: indexPath!.row)!
        
        switch (leaf.LeafType){
        case .Empty:
            updateEmptyLeaf()
            break;
        case .GreenFrog:
            frogImage.isHidden = false
            if leaf.IsSelected {
                frogImage.image = #imageLiteral(resourceName: "green_frog_board_selected")
            }else {
                frogImage.image = #imageLiteral(resourceName: "green_frog_board")
            }
            break;
        case .RedFrog:
            frogImage.isHidden = false
            if leaf.IsSelected {
                frogImage.image = #imageLiteral(resourceName: "red_frog_board_selected")
            }else {
                frogImage.image = #imageLiteral(resourceName: "red_frog_board")
            }
            break;
        }
        
        if leaf.IsValidHop {
            leafImage.image = #imageLiteral(resourceName: "board_leaf_hoppable")
        } else{
            leafImage.image = #imageLiteral(resourceName: "board_leaf")
        }
    }
    
    private func updateEmptyLeaf() {
        if frogImage.isHidden == false {
            // Checking if we need to animate an eating frog
            if(isFrogEaten) {
                // (For a case the old cell before recreation was red)
                frogImage.image = #imageLiteral(resourceName: "green_frog_board")
                
                // Animate the frog to 0% opacity. After the animation ends,
                // setting it hidden and back the alpha for next time.
                UIView.animate(withDuration: LeafCollectionViewCell.FADE_OUT_ANIM_DURATION, delay: 0.5, options: .curveEaseOut, animations: {
                    self.frogImage.alpha = 0.0
                }, completion: { [weak self]
                    (finished: Bool) -> Void in
                    self?.frogImage.isHidden = true
                    // Setting back the alpha for next time
                    self?.frogImage.alpha = 1.0
                })
            } else{
                // No animation needed
                frogImage.isHidden = true
            }
        }
        isFrogEaten = false
    }
}
