//
//  MainPageViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/7/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public var PageChangeReactor:PageChangeReactor?
    public var CurrentIndex:Int=1
    public var subViewControllers:[UIViewController] = {
        return[
            UIStoryboard(name:"Main",bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC,
            UIStoryboard(name:"Main",bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController,
            UIStoryboard(name:"Main",bundle: nil).instantiateViewController(withIdentifier: "FileTableViewController") as! FileTableViewController,
        ]
    }()
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex:Int = subViewControllers.firstIndex(of: viewController) ?? 0
        if (currentIndex<=0){
            return nil
        }
        return subViewControllers[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.firstIndex(of: viewController) ?? 0
        if (currentIndex>=subViewControllers.count-1){
            return nil
        }
        return subViewControllers[currentIndex+1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        let index = subViewControllers.firstIndex(of: pendingViewControllers[0])!
        PageChangeReactor?.OnPageChange(index: index)
        CurrentIndex = index

    }
    



    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        CurrentIndex = 1
        setViewControllers([subViewControllers[CurrentIndex]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
}
public protocol PageChangeReactor {
    func OnPageChange(index:Int)
}
