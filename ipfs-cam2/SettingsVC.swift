//
//  SettingsVC.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 10/29/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    static public var CurrentPhotoPurpose:String = ""
    @IBOutlet weak var PurposeField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PurposeField.text = SettingsVC.CurrentPhotoPurpose
    }
    
    @IBAction func PhotoPurposeEditingEnded(_ sender: Any) {
        let label = sender as! UITextField
        SettingsVC.CurrentPhotoPurpose = label.text!
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
