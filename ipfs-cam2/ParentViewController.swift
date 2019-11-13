//
//  ParentViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/7/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit
import AVFoundation
import TrueTime



class ParentViewController: UIViewController, PageChangeReactor {
    
    func OnPageChange(index: Int) {
        for i in 0...buttons.count-1 {
            buttons[i].isHighlighted = index==i
//            print(index==i)
        }
    }
    var buttons:[UIButton] = []
    var currentIndex:Int = 0
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var FilesButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    
    var PageVC:MainPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsVC.LoadSavedUserValues()
        Constants.NTPClient = TrueTimeClient.sharedInstance
        Constants.NTPClient!.start()
        
        
        // Do any additional setup after loading the view.
        buttons = [SettingsButton, CameraButton, FilesButton]
        for i in 0...buttons.count-1 {

            buttons[i].isHighlighted = PageVC?.CurrentIndex==i
            buttons[i].addTarget(self, action:  #selector(switchPageButtonPressed(_:)), for: .touchUpInside)
        }
        
    }
    
    @objc func switchPageButtonPressed(_ sender: UIButton) {
        let nextIndex = buttons.firstIndex(of: sender) ?? 0
        let currentIndex = PageVC!.CurrentIndex
        var direction = UIPageViewController.NavigationDirection.forward
        if (nextIndex<currentIndex){
            direction = .reverse
        }
        PageVC!.CurrentIndex = nextIndex
        PageVC!.setViewControllers([PageVC!.subViewControllers[nextIndex]], direction: direction, animated: true, completion: nil)
        let seconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.OnPageChange(index: nextIndex)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        PageVC = segue.destination as? MainPageViewController
        PageVC?.PageChangeReactor=self
       
    }
 

}
