//
//  MainPageViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/7/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var subViewControllers:[UIViewController] = {
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self

        setViewControllers([subViewControllers[1]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
