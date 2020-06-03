//
//  ActivityView.swift
//  InstagramApp
//
//  Created by Gwinyai on 28/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ActivityView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var activityData: [Activity] = [Activity]() {
        
        didSet {
            
            tableView.reloadData()
            
        }
        
    }
    
    weak var activityDelegate: ActivityDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(80.0)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activityData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell") as! ActivityTableViewCell
        
        cell.profileImage.image = activityData[indexPath.row].userImage
        
        cell.detailsLabel.text = activityData[indexPath.row].details
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activityDelegate?.activityDidTouch()
        
    }
    

}
