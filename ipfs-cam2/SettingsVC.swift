//
//  SettingsVC.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 10/29/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit
import Alamofire

class SettingsVC: UIViewController,  ImageFileHandler, UITextFieldDelegate{

    // Settings Delegate functions
    
    func OnFileUploadFinish(file: CorroDataFile) {
        if (SettingsVC.DeleteLocalPhotos){
            ImageHandler.remove(fileName: file.FileName)
        }
        if (!SettingsVC.UploadToAuditorNode){
            let parameters: Parameters = ["ipfs_pin_hash":file.CID!]
            
            Alamofire.request(Constants.RemovePinURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.PinataHeaders).response(completionHandler: {
                response in
                print("removed pin with status code: \(String(describing: response.response?.statusCode))")
                if (response.error != nil){
                    print("error: \(String(describing: response.error))")
                }
               })
        }
    }
    
    func OnFileUploadError() {
        
    }

    static public var UserEncryptionKey:String = ""
    static public var CurrentPhotoPurpose:String = ""
    static public var CurrentInvestigationID:String = ""
    static public var UploadToAuditorNode:Bool = false
    static public var DeleteLocalPhotos:Bool = false
    static private var LoadedVariables:Bool = false
    
    
    // UI elements:
    // fields
    @IBOutlet weak var EncryptionKeyField: UITextField!
    @IBOutlet weak var PurposeField: UITextField!
    @IBOutlet weak var InvestigationIDField: UITextField!
    
    // switches
    @IBOutlet weak var UploadToAuditorSwitch: UISwitch!
    @IBOutlet weak var DeletePhotosSwitch: UISwitch!
    
    
    static func GetStorageLocationLiteral() -> String{
        if (UploadToAuditorNode && DeleteLocalPhotos){
            return "IPFS"
        }
        else if (UploadToAuditorNode && !DeleteLocalPhotos){
            return "IPFS, DEVICE"
        }
        
        return "DEVICE"
    }
    
    
    static func LoadSavedUserValues(){
        // fields
        CurrentPhotoPurpose = UserDefaults.standard.string(forKey: Constants.CurrentPhotoPurposeKey) ?? ""
        CurrentInvestigationID = UserDefaults.standard.string(forKey: Constants.CurrentInvestigationIDKey) ?? ""
        UserEncryptionKey = UserDefaults.standard.string(forKey: Constants.UserEncryptionKeyKey) ?? Constants.UserDefaultEncryptionKey
        
        if (UserDefaults.standard.object(forKey: Constants.UploadToAuditorNodeKey)
            != nil){
            UploadToAuditorNode = UserDefaults.standard.bool(forKey: Constants.UploadToAuditorNodeKey)
        }
        else{
            UploadToAuditorNode = true
        }
        
        if (UploadToAuditorNode){
            DeleteLocalPhotos = UserDefaults.standard.bool(forKey: Constants.DeleteLocalPhotosKey)
            
        }
        else{
            DeleteLocalPhotos = false
        }
        
        LoadedVariables = true
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!SettingsVC.LoadedVariables){
            SettingsVC.LoadSavedUserValues()
            print("ERROR WARNING: variables should have already been loaded!!")
        }
        
        DataManager.fileUploadDelegate.append(self)

        // fields
        PurposeField.text = SettingsVC.CurrentPhotoPurpose
        InvestigationIDField.text = SettingsVC.CurrentInvestigationID
        EncryptionKeyField.text = SettingsVC.UserEncryptionKey
        
        // switches
        UploadToAuditorSwitch.isOn = SettingsVC.UploadToAuditorNode
        DeletePhotosSwitch.isOn = SettingsVC.DeleteLocalPhotos
        EnableUserToChangeDeleteLocalPhotos(uploadToAuditorValue: SettingsVC.UploadToAuditorNode)
    
        EncryptionKeyField.delegate=self
        InvestigationIDField.delegate=self
        PurposeField.delegate=self
        
        
    }
    
    

    private func EnableUserToChangeDeleteLocalPhotos(uploadToAuditorValue:Bool){
        if (!uploadToAuditorValue && DeletePhotosSwitch.isOn){
            DeletePhotosSwitch.isOn = false
        }
        
        DeletePhotosSwitch.isEnabled = uploadToAuditorValue
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        PurposeField.text = SettingsVC.CurrentPhotoPurpose
    }
    
    
    @IBAction func PhotoPurposeEdited(_ sender: Any) {
        let label = sender as! UITextField
        SettingsVC.CurrentPhotoPurpose = label.text!
        SaveSettingsVar(value: label.text!, key: Constants.CurrentPhotoPurposeKey)
    }
    
    @IBAction func EncryptionKeyEdited(_ sender: Any) {
        let val = (sender as! UITextField).text!
        SettingsVC.UserEncryptionKey = val
        SaveSettingsVar(value: val, key: Constants.UserEncryptionKeyKey)

    }
    
    @IBAction func InvestigationIDEdited(_ sender: Any) {
        let label = sender as! UITextField
        SettingsVC.CurrentInvestigationID = label.text!
        SaveSettingsVar(value: label.text!, key: Constants.CurrentInvestigationIDKey)
    }
    
    
    @IBAction func UploadToAuditorNodeValueChanged(_ sender: Any) {
        let val = (sender as! UISwitch).isOn
        SettingsVC.UploadToAuditorNode = val
        SaveSettingsVar(value:val, key: Constants.UploadToAuditorNodeKey)
        EnableUserToChangeDeleteLocalPhotos(uploadToAuditorValue: val)
    }
    
    
    @IBAction func DeleteLocalPhotosValueChanged(_ sender: Any) {
        let val = (sender as! UISwitch).isOn
        SettingsVC.DeleteLocalPhotos = val
        SaveSettingsVar(value:val, key: Constants.DeleteLocalPhotosKey)
    }
    
    
    private func SaveSettingsVar(value:String, key:String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func SaveSettingsVar(value:Bool, key:String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
