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
    
    var connectedDevices : [Device]!
    var progressValue : Float = 0.0
    var isScanRunning : BooleanLiteralType = false
    var lanScanner : MMLANScanner!
    var delegate : MainPresenterDelegate?
    
    //MARK: - Custom init method
    init(delegate:MainPresenterDelegate?){
      
        super.init()
        
        self.delegate = delegate!
        
        isScanRunning = false
        
        lanScanner = MMLANScanner(delegate:self)
    }
    
    //MARK: - Button Actions
    func scanButtonClicked()-> Void {
    
    }
    
    func startNetWorkScan() ->Void{
       
        if (isScanRunning) {
            
            isScanRunning = true
            lanScanner.start()
        }
    }
  
    func stopNetWorkScan() ->Void{
        
        lanScanner.stop()
        isScanRunning = false
    }
    
    
    func ssidName() -> String {
        
        return LANProperties.fetchSSIDInfo()
    }
    
     // MARK: - MMLANScanner Delegates
    func lanScanDidFindNewDevice(_ device: Device!) {
       
        connectedDevices?.append(device)
        
    }
    
    func lanScanDidFailedToScan() {
        isScanRunning = false
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        
    }

}
