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
  
    private var myContext = 0
    var presenter: MainPresenter!
    
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter = MainPresenter(delegate:self)
        
        self.presenter.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:&myContext)
        self.presenter.addObserver(self, forKeyPath: "progressValue", options: .new, context:&myContext)
        self.presenter.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:&myContext)
    
        self.navigationBarTitle.title = self.presenter.ssidName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Action
    @IBAction func refresh(_ sender: Any) {

        self.showProgressBar()
        self.navigationBarTitle.title = self.presenter.ssidName()
        self.presenter.scanButtonClicked()
    }
    
    //MARK: - Show/Hide Progress Bar
    func showProgressBar()->Void {
        
        self.progressView.progress = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tableVTopContraint.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
        
    func hideProgressBar()->Void {
            
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tableVTopContraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
            
    }
    
    //MARK: - Presenter Delegates
    func mainPresenterIPSearchFinished() {
        
        self.hideProgressBar()
        self.showAlert(title: "Scan Finished", message: "Number of devices connected to the Local Area Network : \(self.presenter.connectedDevices.count)")
    }
    
    func mainPresenterIPSearchCancelled() {

        self.hideProgressBar()
        self.tableV.reloadData()
    }
    
    func mainPresenterIPSearchFailed() {
        
        self.hideProgressBar()
        self.showAlert(title: "Failed to scan", message: "Please make sure that you are connected to a WiFi before starting LAN Scan")
    }
    
    //MARK: - Alert Controller
    
    func showAlert(title:String, message: String) {
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
     
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
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
        
        let device = self.presenter.connectedDevices[indexPath.row] 
        
        cell.ipLabel.text = device.ipAddress
        cell.macAddressLabel.text = device.macAddress
        cell.hostnameLabel.text = device.hostname
        cell.brandLabel.text = device.brand
        
        return cell
    }
    
    //MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        
        if (context == &myContext) {
        
            if (keyPath == "connectedDevices") {
                
                self.tableV.reloadData()
            }
            else if (keyPath == "progressValue") {
                
                self.progressView.progress = self.presenter.progressValue
            }
            else if (keyPath == "isScanRunning") {
                
                let isScanRunning = change?[.newKey] as! BooleanLiteralType
                self.scanButton.image = isScanRunning ? #imageLiteral(resourceName: "stopBarButton") : #imageLiteral(resourceName: "refreshBarButton")

            }
        
        }
    }
    
    //MARK: - Deinit
    deinit {
        
        self.presenter.removeObserver(self, forKeyPath: "connectedDevices")
        self.presenter.removeObserver(self, forKeyPath: "progressValue")
        self.presenter.removeObserver(self, forKeyPath: "isScanRunning")
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
