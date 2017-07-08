//
//  MainPresenter.swift
//  MMLanScanSwiftDemo
//
//  Created by Michalis Mavris on 06/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

import UIKit
import Foundation

protocol MainPresenterDelegate {
    func mainPresenterIPSearchFinished()
    func mainPresenterIPSearchCancelled()
    func mainPresenterIPSearchFailed()
}

class MainPresenter: NSObject, MMLANScannerDelegate {
    
    dynamic var connectedDevices : [MMDevice]!
    dynamic var progressValue : Float = 0.0
    dynamic var isScanRunning : BooleanLiteralType = false
    
    var lanScanner : MMLANScanner!
    var delegate : MainPresenterDelegate?
    
    //MARK: - Custom init method
    //Initialization with delegate
    init(delegate:MainPresenterDelegate?){
      
        super.init()
        
        self.delegate = delegate!
        
        self.connectedDevices = [MMDevice]()
        
        self.isScanRunning = false
        
        self.lanScanner = MMLANScanner(delegate:self)
    }
    
    //MARK: - Button Actions
    //This method is responsible for handling the tap button action on MainVC. In case the scan is running and the button is tapped it will stop the scan
    func scanButtonClicked()-> Void {
    
        if (self.isScanRunning) {
           
            self.stopNetWorkScan()
        }
        else {
            
            self.startNetWorkScan()
        }
    }
    
    func startNetWorkScan() ->Void{
       
        if (self.isScanRunning) {
            
            self.stopNetWorkScan()
            self.connectedDevices.removeAll()
        }
        else {
            self.connectedDevices.removeAll()
            self.isScanRunning = true
            self.lanScanner.start()
        }
    }
  
    func stopNetWorkScan() ->Void{
        
        self.lanScanner.stop()
        self.isScanRunning = false
    }
    
    //MARK: - SSID Info
    //Getting the SSID string using LANProperties
    func ssidName() -> String {
        
        return LANProperties.fetchSSIDInfo()
    }
    
     // MARK: - MMLANScanner Delegates
     //The delegate methods of MMLANScanner
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        //Adding the found device in the array
        if(!self.connectedDevices .contains(device)) {
            self.connectedDevices?.append(device)
        }

        let ipSortDescriptor = NSSortDescriptor(key: "ipAddress", ascending: true)
        self.connectedDevices = (self.connectedDevices as NSArray).sortedArray(using: [ipSortDescriptor]) as! Array
    }
    
    func lanScanDidFailedToScan() {
        
        self.isScanRunning = false
        self.delegate?.mainPresenterIPSearchFailed()
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
       
        self.isScanRunning = false
        
        //Checks the status of finished. Then call the appropriate method
        if (status == MMLanScannerStatusFinished) {
        
            self.delegate?.mainPresenterIPSearchFinished()
        }
        else if (status == MMLanScannerStatusCancelled) {
            
            self.delegate?.mainPresenterIPSearchCancelled()
        }
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
       
        //Updating the progress value. MainVC will be notified by KVO
        self.progressValue = pingedHosts / Float(overallHosts)
    }

}
