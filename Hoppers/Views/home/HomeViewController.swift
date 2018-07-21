//
//  ViewController.swift
//  Hoppers
//
//  Created by tamir on 5/23/18.
//  Copyright © 2018 tamir. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, ManagerInitiatedDelegate {
    
    // MARK: Consts
    
    private static let FROGS_ANIMATION_DURATION: Double = 1.5
    
    // MARK: Members
    
    @IBOutlet weak var greenFrogImage: UIImageView!
    @IBOutlet weak var redFrogImage: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var loadingImage: UIImageView!
    
    private var loadingAnimation: CABasicAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingScreen()
        
        // Initializing the manager and waiting for the proccess to finish:
        let context : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        GameManager.getInstance().initializeManager(context: context)
        // Registering to the event when the manager has finished initializing
        GameManager.getInstance().managerInitiatedDelegate = self
        
        // Setting click event for the start playing button:
        let playGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playTapped(tapGestureRecognizer:)))
        playButton.addGestureRecognizer(playGestureRecognizer)
        playButton.isUserInteractionEnabled = true
        
        // Setting navigation bar transparent:
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @objc func playTapped(tapGestureRecognizer: UITapGestureRecognizer){
        // Moving to the difficulty choosing view:
        let difficultyController = self.storyboard?.instantiateViewController(withIdentifier: "DifficultyViewController") as! DifficultyViewController
        self.navigationController!.pushViewController(difficultyController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startFrogsAnimations(){
        DispatchQueue.main.async { [weak self] in
            var greenFrogImages :[UIImage] = []
            var redFrogImages :[UIImage] = []
            
            for count in 1...5{
                // Creating the name of the current count images:
                let strRedFrogImageName : String = "home_screen_frog_red_\(count).png"
                let strGreenFrogImageName : String = "home_screen_frog_green_\(count).png"
                
                // Creating images:
                let redFrogImage  = UIImage(named:strRedFrogImageName)
                let greenFrogImage  = UIImage(named:strGreenFrogImageName)
                
                // Adding images to the array
                greenFrogImages.append(greenFrogImage!)
                redFrogImages.append(redFrogImage!)
                
                // Adding the last image twice to make the loop last longer
                if count == 5 {
                    greenFrogImages.append(greenFrogImage!)
                    redFrogImages.append(redFrogImage!)
                }
            }
            
            // Starting animations:
            
            self?.greenFrogImage.animationImages = greenFrogImages
            self?.greenFrogImage.animationDuration = HomeViewController.FROGS_ANIMATION_DURATION
            self?.greenFrogImage.startAnimating()
            
            self?.redFrogImage.animationImages = redFrogImages
            self?.redFrogImage.animationDuration = HomeViewController.FROGS_ANIMATION_DURATION
            self?.redFrogImage.startAnimating()
        }
    }
    
    private func showLoadingScreen(){
        // Showing the loading view:
        loadingView.isHidden = false
        
        // Hiding the other views
        greenFrogImage.isHidden = true
        redFrogImage.isHidden = true
        playButton.isHidden = true
        
        // Spinning the loading image:
        loadingAnimation = CABasicAnimation(keyPath: "transform.rotation")
        loadingAnimation?.fromValue = 0.0
        loadingAnimation?.toValue = Double.pi * 2
        loadingAnimation?.duration = 1
        loadingAnimation?.repeatCount = .infinity
        loadingImage.layer.add(loadingAnimation!, forKey: nil)
    }
    
    private func hideLoadingScreen(){
        DispatchQueue.main.async { [weak self] in
            // Hiding the loading view:
            self?.loadingView.isHidden = true
            
            // Showing the other views
            self?.greenFrogImage.isHidden = false
            self?.redFrogImage.isHidden = false
            self?.playButton.isHidden = false
            
            // Stopping the loading image animation:
            self?.loadingImage.layer.removeAllAnimations()
        }
    }
    
    func managerInitiated() {
        hideLoadingScreen()
        startFrogsAnimations()
    }
}

