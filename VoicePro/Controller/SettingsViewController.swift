//
//  SettingsViewController.swift
//  Metals
//
//  Created by Rahul on 23/07/24.
//

import UIKit
import SnapKit

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let settingsArray = ["Audio Files", "Reset"]
    let settingsImageArray = ["person.crop.circle", "iphone.and.arrow.forward"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#292C30")
        setupTableView()
    }
    
    func setupTableView() {
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        
        cell.backgroundColor = UIColor(hexString: "#292C30")
        cell.titleLabel.textColor = .white
        cell.titleLabel.font = .boldSystemFont(ofSize: 16)
        cell.imgView.image = UIImage(systemName: settingsImageArray[indexPath.row])
        cell.imgView.tintColor = UIColor(hexString: "#F29F58")
        cell.titleLabel.text = settingsArray[indexPath.row]
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AudioFileListVC") as! AudioFileListVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            showToast()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func topViewController() -> UIViewController? {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            return nil
        }
        var topVC = rootVC
        
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
    
}
