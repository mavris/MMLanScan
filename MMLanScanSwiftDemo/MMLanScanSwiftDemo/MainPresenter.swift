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
    
    dynamic var connectedDevices : [Device]!
    dynamic var progressValue : Float = 0.0
    dynamic var isScanRunning : BooleanLiteralType = false
    var lanScanner : MMLANScanner!
    var delegate : MainPresenterDelegate?
    
    //MARK: - Custom init method
    init(delegate:MainPresenterDelegate?){
      
        super.init()
        
        self.delegate = delegate!
        
        self.connectedDevices = [Device]()
        
        self.isScanRunning = false
        
        self.lanScanner = MMLANScanner(delegate:self)
    }
    
    //MARK: - Button Actions
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
        }
        else {
            
            self.isScanRunning = true
            self.lanScanner.start()
        }
    }
  
    func stopNetWorkScan() ->Void{
        
        self.lanScanner.stop()
        self.isScanRunning = false
    }
    
    //MARK: - SSID Info
    func ssidName() -> String {
        
        return LANProperties.fetchSSIDInfo()
    }
    
     // MARK: - MMLANScanner Delegates
    func lanScanDidFindNewDevice(_ device: Device!) {

        self.connectedDevices?.append(device)
    }
    
    func lanScanDidFailedToScan() {

        self.isScanRunning = false
        self.delegate?.mainPresenterIPSearchFailed()
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
       
        self.isScanRunning = false
        
        if (status == MMLanScannerStatusFinished) {
        
            self.delegate?.mainPresenterIPSearchFinished()
        }
        else if (status == MMLanScannerStatusCancelled) {
            
            self.delegate?.mainPresenterIPSearchCancelled()
        }
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        
        self.progressValue = pingedHosts / Float(overallHosts)
    }

}
