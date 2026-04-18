//
//  StartViewController.swift
//  The Submarine
//
//  Created by Николай Завгородний on 21.07.2025.
//

import UIKit

class StartViewController: UIViewController, Storyboarded {
    
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var leaderboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()
        setupInitialState()
    }
    
    @IBAction private func openGameVCButtonPressed(_ sender: UIButton) {
        let vc = GameViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func openSettingsVCButtonPressed(_ sender: UIButton) {
        let vc = SettingsViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func openLeaderboardVCButtonPressed(_ sender: UIButton) {
        let vc = LeaderboardViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupInitialState() {
        setupView()
        setupButtons()
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "StartBackground")
        imageView.contentMode = .scaleAspectFill
        view.insertSubview(imageView, at: 0)
    }
    
    private func setupButtons() {
        buttons.forEach { 
            $0.round()
            $0.dropShadow()
            $0.addGradient([UIColor.white.cgColor, UIColor.systemBlue.cgColor, UIColor.systemRed.cgColor])
        }
        settingsButton.setTitle("Settings".localize(), withMultiplier: 0.38)
        startButton.setTitle("Start".localize(), withMultiplier: 0.55)
        leaderboardButton.setTitle("Leaderboard".localize(), withMultiplier: 0.33)
    }
    
}
