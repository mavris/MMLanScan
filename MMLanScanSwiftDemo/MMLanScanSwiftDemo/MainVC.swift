//
//  MainVC.swift
//  MMLanScanSwiftDemo
//
//  Created by Michalis Mavris on 06/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

import UIKit
import Foundation

class MainVC: UIViewController, MainPresenterDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableVTopContraint: NSLayoutConstraint!
    @IBOutlet weak var scanButton: UIBarButtonItem!

    var presenter: MainPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MainPresenter(delegate:self)
        
        presenter.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:nil)
        presenter.addObserver(self, forKeyPath: "progressValue", options: .new, context:nil)
        presenter.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:nil)
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Presenter Delegates
    func mainPresenterIPSearchFinished() {
    
    }
    
    func mainPresenterIPSearchCancelled() {
    
    }
    
    func mainPresenterIPSearchFailed() {
    
    }
    
    
    //MARK: - UITableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.presenter.connectedDevices!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        
        let device = self.presenter.connectedDevices[indexPath.row] as! Device
        
        cell.ipLabel.text = device.ipAddress
        cell.macAddressLabel.text = device.macAddress
        cell.hostnameLabel.text = device.hostname
        cell.brandLabel.text = device.brand
        
        return cell
    }
    
    //MARK: - KVO
    func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer) {
        
        if (object as! NSObject == self) {
        
            if (keyPath == "connectedDevices") {
                
                self.tableV.reloadData()
            }
            else if (keyPath == "progressValue") {
            
                self.progressView.progress = self.presenter.progressValue
            }
            else if (keyPath == "isScanRunning") {
                
                let lowercase = change?[.newKey] as! String
                
                let isScanRunning = lowercase == "true" || lowercase == "1" || lowercase == "yes" || lowercase == "on"
                
                self.scanButton.image = isScanRunning ? #imageLiteral(resourceName: "stopBarButton") : #imageLiteral(resourceName: "refreshBarButton")

            }
        
        }
    }
    
    deinit {
        
        presenter.removeObserver(self, forKeyPath: "connectedDevices")
        presenter.removeObserver(self, forKeyPath: "progressValue")
        presenter.removeObserver(self, forKeyPath: "isScanRunning")

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
