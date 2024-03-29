/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit

enum RegistrationItems: Int
{
    case UserId
    case ChannelId
    case AppKey
    case Registration
    
    static let count: Int = 4
}

class RegistrationVC : UITableViewController
{
    var registrationCounter = 0
    var registrationObserver: AnyObject?
    var registrationUpdatedObserver: AnyObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registrationCounter = 0
        super.viewWillAppear(animated)
        registrationObserver = NotificationCenter.default.addObserver(forName: MCENotificationName.MCERegistered.rawValue, object: nil, queue: OperationQueue.main, using: { (notification: Notification) -> Void in
            self.refresh(sender: nil)
            self.registrationCounter = self.registrationCounter + 1
        })
        registrationUpdatedObserver = NotificationCenter.default.addObserver(forName: MCENotificationName.MCERegistrationChanged.rawValue, object: nil, queue: OperationQueue.main, using: { (notification: Notification) -> Void in
            self.refresh(sender: nil)
            self.registrationCounter = self.registrationCounter + 1
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let registrationObserver = registrationObserver {
            NotificationCenter.default.removeObserver(registrationObserver)
            self.registrationObserver = nil
        }
        if let registrationUpdatedObserver = registrationUpdatedObserver {
            NotificationCenter.default.removeObserver(registrationUpdatedObserver)
            self.registrationUpdatedObserver = nil
        }
    }
    
    @IBAction func refresh(sender: AnyObject?) {
        if let s = sender
        {
            s.endRefreshing()
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "view", for: indexPath as IndexPath)
        cell.detailTextLabel!.accessibilityIdentifier = nil
        cell.accessibilityIdentifier = nil
        if let registrationItem = RegistrationItems(rawValue: indexPath.item)
        {
            switch(registrationItem)
            {
            case .UserId:
                cell.textLabel!.text = "User Id"
                cell.detailTextLabel!.text = MCERegistrationDetails.shared.userId
                cell.detailTextLabel!.accessibilityIdentifier = "userId"
                break
            case .ChannelId:
                cell.textLabel!.text = "Channel Id"
                cell.detailTextLabel!.text = MCERegistrationDetails.shared.channelId
                cell.detailTextLabel!.accessibilityIdentifier = "channelId"
                break
            case .AppKey:
                cell.textLabel!.text = "App Key"
                cell.detailTextLabel!.text = MCERegistrationDetails.shared.appKey
                cell.detailTextLabel!.accessibilityIdentifier = "appKey"
                break
            case .Registration:
                cell.accessibilityIdentifier = "registration"
                cell.accessibilityValue = "\(registrationCounter)"
                cell.textLabel!.text = "Registration"
                if MCERegistrationDetails.shared.mceRegistered
                {
                    cell.detailTextLabel!.text = "Registered"
                }
                else
                {
                    cell.detailTextLabel!.text = "Click to start"
                }
                
                break
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RegistrationItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Credentials"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        return "User ID and Channel ID are known only after registration. The registration process could take several minutes. If you have have issues with registering a device, make sure you have the correct certificate and appKey."
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        guard let item = RegistrationItems(rawValue: indexPath.item) else {
            return
        }
        switch item {
        case .Registration:
            if !MCERegistrationDetails.shared.mceRegistered {
                MCESdk.shared.manualInitialization()
            }
        case .AppKey:
            UIPasteboard.general.string = MCEConfig.shared.appKey
        case .ChannelId:
            UIPasteboard.general.string = MCERegistrationDetails.shared.channelId
        case .UserId:
            UIPasteboard.general.string = MCERegistrationDetails.shared.userId
        }

    }
}
