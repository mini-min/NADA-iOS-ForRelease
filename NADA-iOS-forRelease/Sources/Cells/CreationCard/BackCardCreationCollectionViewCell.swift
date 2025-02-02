//
//  BackCardCreationCell.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2021/09/24.
//

import UIKit

import FirebaseAnalytics
import IQKeyboardManagerSwift

class BackCardCreationCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "BackCardCreationCollectionViewCell"
    
    public var cardType: CardType?
    
    private var tasteInfo: [String]?
    private let maxLength: Int = 140
    private var requiredCollectionViewList = [UICollectionView]()
    private var preTasteInfo: [CardTasteInfo]?
    
    public weak var backCardCreationDelegate: BackCardCreationDelegate?
    
    // MARK: - @IBOutlet Properties
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var requiredInfoTextLabel: UILabel!
    @IBOutlet weak var optionalInfoTextLabel: UILabel!
    
    @IBOutlet weak var tmiTextView: UITextView!
    
    @IBOutlet weak var firstTasteCollectionView: UICollectionView!
    @IBOutlet weak var secondTasteCollectionView: UICollectionView!
    @IBOutlet weak var thirdTasteCollectionView: UICollectionView!
    @IBOutlet weak var fourthTasteCollectionView: UICollectionView!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: - Cell Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
        setAddTargets()
        registerCell()
        textViewDelegate()
        setNotification()
    }
}

// MARK: - Extensions

extension BackCardCreationCollectionViewCell {
    private func setUI() {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        initCollectionViewList()
        
        scrollView.indicatorStyle = .default
        scrollView.backgroundColor = .background
        bgView.backgroundColor = .background
        
        _ = requiredCollectionViewList.map { $0.backgroundColor = .background }
        
        let requiredAttributeString = NSMutableAttributedString(string: "*나의 취향을 골라보세요.")
        requiredAttributeString.addAttribute(.foregroundColor, value: UIColor.mainColorNadaMain, range: NSRange(location: 0, length: 1))
        requiredAttributeString.addAttribute(.foregroundColor, value: UIColor.secondary, range: NSRange(location: 1, length: requiredAttributeString.length - 1))
        requiredInfoTextLabel.attributedText = requiredAttributeString
        requiredInfoTextLabel.font = .textBold01
        
        refreshButton.setTitle("", for: .normal)
        refreshButton.setBackgroundImage(UIImage(named: "icnRandom"), for: .normal)
        refreshButton.setBackgroundImage(UIImage(named: "icnHoverRandom"), for: .highlighted)
        
        optionalInfoTextLabel.text = "나의 재밌는 TMI를 알려주세요."
        optionalInfoTextLabel.textColor = .secondary
        optionalInfoTextLabel.font = .textBold01
        
        tmiTextView.tintColor = .primary
        tmiTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tmiTextView.backgroundColor = .textBox
        tmiTextView.font = .textRegular04
        tmiTextView.text = "조금 더 다채로운 모습을 담아볼까요?"
        tmiTextView.textColor = .quaternary
        tmiTextView.layer.cornerRadius = 10
    }
    private func initCollectionViewList() {
        requiredCollectionViewList.append(contentsOf: [
            firstTasteCollectionView,
            secondTasteCollectionView,
            thirdTasteCollectionView,
            fourthTasteCollectionView
        ])
    }
    private func registerCell() {
        _ = requiredCollectionViewList.map {
            $0.delegate = self
            $0.dataSource = self
            $0.register(RequiredFlavorCollectionViewCell.nib(), forCellWithReuseIdentifier: Const.Xib.requiredCollectionViewCell)
        }
    }
    private func textViewDelegate() {
        tmiTextView.delegate = self
    }
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: .touchRequiredView, object: nil)
    }
    private func checkBackCardStatus() {
        guard let tasteInfo else { return }
        
        backCardCreationDelegate?.backCardCreation(withRequired: [
            firstTasteCollectionView.indexPathsForSelectedItems == [[0, 0]] ? tasteInfo[0] : tasteInfo[1],
            secondTasteCollectionView.indexPathsForSelectedItems == [[0, 0]] ? tasteInfo[2] : tasteInfo[3],
            thirdTasteCollectionView.indexPathsForSelectedItems == [[0, 0]] ? tasteInfo[4] : tasteInfo[5],
            fourthTasteCollectionView.indexPathsForSelectedItems == [[0, 0]] ? tasteInfo[6] : tasteInfo[7]
        ], withOptional: tmiTextView.text == "조금 더 다채로운 모습을 담아볼까요?" ? nil : tmiTextView.text)
    }
    private func setAddTargets() {
        refreshButton.addTarget(self, action: #selector(touchRefreshButton), for: .touchUpInside)
    }
    static func nib() -> UINib {
        return UINib(nibName: Const.Xib.backCardCreationCollectionViewCell, bundle: Bundle(for: BackCardCreationCollectionViewCell.self))
    }
    public func setPreBackCard(tastes: [CardTasteInfo], tmi: String?) {
        preTasteInfo = tastes
                
        if let tmi {
            tmiTextView.text = tmi
            tmiTextView.textColor = .primary
        } else {
            tmiTextView.text = "조금 더 다채로운 모습을 담아볼까요?"
        }
        
        backCardCreationDelegate?.backCardCreation(requiredInfo: true)
        
        let choosedTastes: [String] = tastes.filter { $0.isChoose == true }.map { $0.cardTasteName }
        backCardCreationDelegate?.backCardCreation(withRequired: choosedTastes, withOptional: tmi)
    }
    public func setTasteInfo(_ tasteInfo: [String]) {
        self.tasteInfo = tasteInfo
    }
    // MARK: - @objc Methods
    
    @objc
    private func dismissKeyboard() {
        tmiTextView.resignFirstResponder()
    }
    @objc
    private func touchRefreshButton() {
        preTasteInfo = nil
        backCardCreationDelegate?.backCardCreationTouchRefresh()
        backCardCreationDelegate?.backCardCreation(requiredInfo: false)
        
        guard let cardType else { return }
        
        switch cardType {
        case .basic:
            Analytics.logEvent(Tracking.Event.touchBasicTasteInfo + "다른질문", parameters: nil)
        case .company:
            Analytics.logEvent(Tracking.Event.touchCompanyTasteInfo + "다른질문", parameters: nil)
        case .fan:
            Analytics.logEvent(Tracking.Event.touchFanTasteInfo + "다른질문", parameters: nil)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension BackCardCreationCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        backCardCreationDelegate?.backCardCreation(endEditing: true)
        if firstTasteCollectionView.indexPathsForSelectedItems?.isEmpty == false &&
            secondTasteCollectionView.indexPathsForSelectedItems?.isEmpty == false &&
            thirdTasteCollectionView.indexPathsForSelectedItems?.isEmpty == false &&
            fourthTasteCollectionView.indexPathsForSelectedItems?.isEmpty == false {
            backCardCreationDelegate?.backCardCreation(requiredInfo: true)
        } else {
            backCardCreationDelegate?.backCardCreation(requiredInfo: false)
        }
        checkBackCardStatus()
        
        guard let cardType else { return }
        
        switch cardType {
        case .basic:
            if collectionView == firstTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchBasicTasteInfo + (tasteInfo?[indexPath.item] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == secondTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchBasicTasteInfo + (tasteInfo?[indexPath.item + 2] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == thirdTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchBasicTasteInfo + (tasteInfo?[indexPath.item + 4] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == fourthTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchBasicTasteInfo + (tasteInfo?[indexPath.item + 6] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            }
        case .company:
            if collectionView == firstTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchCompanyTasteInfo + (tasteInfo?[indexPath.item] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == secondTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchCompanyTasteInfo + (tasteInfo?[indexPath.item + 2] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == thirdTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchCompanyTasteInfo + (tasteInfo?[indexPath.item + 4] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == fourthTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchCompanyTasteInfo + (tasteInfo?[indexPath.item + 6] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            }
        case .fan:
            if collectionView == firstTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchFanTasteInfo + (tasteInfo?[indexPath.item] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == secondTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchFanTasteInfo + (tasteInfo?[indexPath.item + 2] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == thirdTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchFanTasteInfo + (tasteInfo?[indexPath.item + 4] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            } else if collectionView == fourthTasteCollectionView {
                Analytics.logEvent(Tracking.Event.touchFanTasteInfo + (tasteInfo?[indexPath.item + 6] ?? "").replacingOccurrences(of: " ", with: "_"), parameters: nil)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension BackCardCreationCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.Xib.requiredCollectionViewCell, for: indexPath) as? RequiredFlavorCollectionViewCell else {
            return UICollectionViewCell()
        }
        switch collectionView {
        case firstTasteCollectionView:
            cell.initCell(flavor: tasteInfo?[indexPath.item] ?? "")
            
            if preTasteInfo?[indexPath.item].isChoose ?? false {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        case secondTasteCollectionView:
            cell.initCell(flavor: tasteInfo?[indexPath.item + 2] ?? "")
            
            if preTasteInfo?[indexPath.item + 2].isChoose ?? false {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        case thirdTasteCollectionView:
            cell.initCell(flavor: tasteInfo?[indexPath.item + 4] ?? "")
            
            if preTasteInfo?[indexPath.item + 4].isChoose ?? false {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        case fourthTasteCollectionView:
            cell.initCell(flavor: tasteInfo?[indexPath.item + 6] ?? "")
            
            if preTasteInfo?[indexPath.item + 6].isChoose ?? false {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        default:
            return UICollectionViewCell()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BackCardCreationCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 7) / 2
        let cellHeight = collectionView.frame.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - UITextViewDelegate

extension BackCardCreationCollectionViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "조금 더 다채로운 모습을 담아볼까요?" {
            textView.text = ""
            textView.textColor = .primary
        }
        textView.borderColor = .primary
        textView.borderWidth = 1
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "조금 더 다채로운 모습을 담아볼까요?"
            textView.textColor = .quaternary
        }
        backCardCreationDelegate?.backCardCreation(endEditing: true)
        checkBackCardStatus()
        textView.borderWidth = 0
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 140 {
            textView.deleteBackward()
        }
    }
}
