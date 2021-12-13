//
//  OpenSourceViewController.swift
//  NADA-iOS-forRelease
//
//  Created by 민 on 2021/12/11.
//

import UIKit

class OpenSourceViewController: UIViewController {

    // MARK: - Properteis
    var openSourceList = ["Moya", "SkeletonView", "SwiftLint", "VerticalCardSwiper", "KakaoSDK", "IQKeyboardManagerSwift"]

    // MARK: - @IBOutlet Properties
    @IBOutlet weak var openSourceTableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        navigationBackSwipeMotion()
    }
    
    // MARK: - @IBAction Properties
    @IBAction func dismissToPreviousView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Extensions
extension OpenSourceViewController {
    
    func setUI() {
        openSourceTableView.register(OpenSourceTableViewCell.nib(), forCellReuseIdentifier: Const.Xib.openSourceTableViewCell)
        
        openSourceTableView.delegate = self
        openSourceTableView.dataSource = self
    }
    
    func navigationBackSwipeMotion() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func openURL(link: URL) {
        if UIApplication.shared.canOpenURL(link) {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
    
}

// MARK: - TableView Delegate
extension OpenSourceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .background
        
        switch indexPath.row {
        case 0: openURL(link: URL(string: Const.URL.moyaURL)!)
        case 1: openURL(link: URL(string: Const.URL.skeletonURL)!)
        case 2: openURL(link: URL(string: Const.URL.swiftLintURL)!)
        case 3: openURL(link: URL(string: Const.URL.cardSwiperURL)!)
        case 4: openURL(link: URL(string: Const.URL.kakaoURL)!)
        case 5: openURL(link: URL(string: Const.URL.keyboardURL)!)
        default: print("default!")
            
        }
    }
    
}

// MARK: - TableView DataSource
extension OpenSourceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openSourceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let serviceCell = tableView.dequeueReusableCell(withIdentifier: Const.Xib.openSourceTableViewCell, for: indexPath) as? OpenSourceTableViewCell else { return UITableViewCell() }
        
        serviceCell.titleLabel.text = openSourceList[indexPath.row]
        
        return serviceCell
    }
}
