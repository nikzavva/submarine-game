//
//  SettingsViewController.swift
//  The Submarine
//
//  Created by Николай Завгородний on 21.07.2025.
//

import UIKit

class SettingsViewController: UIViewController, Storyboarded {
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var submarineCenterView: UIView!
    @IBOutlet private weak var submarineView: UIView!
    @IBOutlet private weak var speedCenterView: UIView!
    @IBOutlet private weak var speedView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    
    private var centerSubmarineImageView = UIImageView()
    private var centerSpeedLabel = UILabel()
    
    private let submarineImages = ["Submarine", "SubmarinePurple", "SubmarineRed"]
    private var speeds = ["Standart speed", "Fast", "Very fast"]
    
    private var currentSubmarineIndex = 0 {
        didSet { currentSubmarineIndex = wrapped(currentSubmarineIndex, count: submarineImages.count) }
    }
    
    private var currentSpeedIndex = 0 {
        didSet { currentSpeedIndex = wrapped(currentSpeedIndex, count: speeds.count) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        setupInitialState()
    }
    
    @IBAction private func showRootVCButtonPressed(_ sender: UIButton) {
        saveSettings()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func showPreviewSubmarineButtonPressed(_ sender: UIButton) {
        moveSubmarine(by: .left)
    }
    
    @IBAction private func showNextSubmarineButtonPressed(_ sender: UIButton) {
        moveSubmarine(by: .right)
    }
    
    @IBAction private func showPreviewSpeedLabelButtonPressed(_ sender: UIButton) {
        moveSpeedLabel(by: .left)
    }
    
    @IBAction private func showNextSpeedLabelButtonPressed(_ sender: UIButton) {
        moveSpeedLabel(by: .right)
    }
    
    private func setupInitialState() {
        localize()
        loadSettings()
        setupBackground()
        setupInitialSubmarine()
        setupInitialSpeed()
    }
    
    private func setupBackground() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "StartBackground")
        imageView.contentMode = .scaleAspectFill
        view.insertSubview(imageView, at: 0)
    }
    
    private func setupInitialSubmarine() {
        centerSubmarineImageView.frame = submarineView.bounds
        centerSubmarineImageView.center = submarineView.center
        centerSubmarineImageView.contentMode = .scaleAspectFit
        centerSubmarineImageView.image = UIImage(named: submarineImages[currentSubmarineIndex])
        submarineCenterView.addSubview(centerSubmarineImageView)
    }
    
    private func setupInitialSpeed() {
        centerSpeedLabel.frame = speedView.bounds
        centerSpeedLabel.center = speedView.center
        centerSpeedLabel.textAlignment = .center
        centerSpeedLabel.text = speeds[currentSpeedIndex]
        speedCenterView.addSubview(centerSpeedLabel)
    }
    
    private func localize() {
        speeds = speeds.map { $0.localize() }
        nameTextField.placeholder = "Enter the name…".localize()
        backButton.setTitle("Back".localize(), for: .normal)
    }
        
    private func moveSubmarine(by direction: MoveDirection) {
        currentSubmarineIndex += direction == .left ? -1 : 1
        
        let newView = UIImageView(frame: submarineView.bounds)
        newView.contentMode = .scaleAspectFit
        newView.image = UIImage(named: submarineImages[currentSubmarineIndex])
        
        placeOffscreen(newView, relativeTo: submarineView, in: submarineCenterView, direction: direction)
        submarineCenterView.addSubview(newView)
        
        animateSwap(oldView: centerSubmarineImageView,
                    newView: newView,
                    relativeTo: submarineView,
                    in: submarineCenterView,
                    direction: direction)
        
        centerSubmarineImageView = newView
    }
    
    private func moveSpeedLabel(by direction: MoveDirection) {
        currentSpeedIndex += direction == .left ? -1 : 1
        
        let newLabel = UILabel(frame: speedView.bounds)
        newLabel.textAlignment = .center
        newLabel.text = speeds[currentSpeedIndex]
        
        placeOffscreen(newLabel, relativeTo: speedView, in: speedCenterView, direction: direction)
        speedCenterView.addSubview(newLabel)
        
        animateSwap(oldView: centerSpeedLabel,
                    newView: newLabel,
                    relativeTo: speedView,
                    in: speedCenterView,
                    direction: direction)
        
        centerSpeedLabel = newLabel
    }
    
    private func placeOffscreen(_ view: UIView,
                                relativeTo contentView: UIView,
                                in containerView: UIView,
                                direction: MoveDirection) {
        let y = contentView.frame.origin.y
        let x: CGFloat = (direction == .left)
        ? containerView.bounds.minX - contentView.bounds.width
        : containerView.bounds.maxX
        view.frame.origin = CGPoint(x: x, y: y)
    }
    
    private func animateSwap(oldView: UIView,
                             newView: UIView,
                             relativeTo contentView: UIView,
                             in containerView: UIView,
                             direction: MoveDirection) {
        UIView.animate(withDuration: 0.3) {
            let oldX: CGFloat = (direction == .left)
            ? containerView.bounds.maxX
            : containerView.bounds.minX - contentView.bounds.width
            oldView.frame.origin.x = oldX
            newView.center = contentView.center
        } completion: { _ in
            oldView.removeFromSuperview()
        }
    }
        
    private func wrapped(_ index: Int, count: Int) -> Int {
        (index % count + count) % count
    }
    
    private func saveSettings() {
        let settings = SettingsData(name: nameTextField.text, submarineIndex: currentSubmarineIndex, speedIndex: currentSpeedIndex)
        UserDefaults.standard.saveSettings(settings)
    }
    
    private func loadSettings() {
        guard let settings = UserDefaults.standard.loadSettings() else { return }
        nameTextField.text = settings.name
        currentSubmarineIndex = settings.submarineIndex
        currentSpeedIndex = settings.speedIndex
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}

private enum MoveDirection {
    case left, right
}
