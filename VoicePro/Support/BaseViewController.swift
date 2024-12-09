//
//  BaseViewController.swift
//  Metals
//
//  Created by Rahul on 31/07/24.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    // MARK: - Setup Methods
    
    func buildUI() {
//        let themeColor = ThemeManager.shared.currentThemeColor
//        view.backgroundColor = themeColor
        view.backgroundColor = UIColor(hexString: "#292C30")
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        let groundImg = UIImageView(image: UIImage(named: "login_background"))
        view.addSubview(groundImg)
        groundImg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.overrideUserInterfaceStyle = .dark
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Logging
    
    func log(_ message: String) {
        print("[\(String(describing: type(of: self)))] \(message)")
    }

    // MARK: - Navigation
    
    func navigate(to viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
