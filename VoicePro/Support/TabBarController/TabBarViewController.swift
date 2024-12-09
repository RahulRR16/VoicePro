//
//  TabBarViewController.swift
//  Metals
//
//  Created by Rahul on 23/07/24.
//

import UIKit
import SnapKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let homeNavVC = UINavigationController(rootViewController: vc)
        homeNavVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let settingsVC = SettingsViewController()
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)
        settingsNavVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        viewControllers = [homeNavVC, settingsNavVC]
        customizeTabBarAppearance()
    }
    
    func customizeTabBarAppearance() {
        // Customize tab bar background color
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .black
        tabBar.layer.cornerRadius = 8
        
        // Customize tab bar item appearance
        let appearance = UITabBarItem.appearance()
        let attributesNormal: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        
        let attributesSelected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hexString: "#F29F58"),
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        
        appearance.setTitleTextAttributes(attributesNormal, for: .normal)
        appearance.setTitleTextAttributes(attributesSelected, for: .selected)
        
        // Customize tab bar shadow
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        
        // Customize tab bar item images
        UITabBar.appearance().tintColor = UIColor(hexString: "#F29F58")
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    @objc func tabBarButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        (view.subviews.last)?.subviews.forEach {
            ($0 as? UIButton)?.isSelected = $0 == sender
        }
    }
}
