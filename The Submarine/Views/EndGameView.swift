//
//  EndGameView.swift
//  The Submarine
//
//  Created by Николай Завгородний on 27.08.2025.
//

import UIKit

class EndGameView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    
    var goBack: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonLayout()
    }
    
    @IBAction private func openRootVCButtonPressed(_ sender: UIButton) {
        goBack?()
    }
    
    static func instanceFromNib() -> EndGameView? {
        UINib(nibName: "EndGameView", bundle: nil)
            .instantiate(withOwner: nil)[0] as? EndGameView
    }
    
    func setResultText(_ text: String) {
        resultLabel.text = text
    }
    
    private func setupView() {
        configureBackButton()
        titleLabel.text = "End of game!".localize()
    }
    
    private func configureBackButton() {
        backButton.round()
        backButton.dropShadow()
        backButton.addGradient([UIColor.white.cgColor, UIColor.systemBlue.cgColor, UIColor.systemRed.cgColor])
        backButton.setTitle("Back".localize(), withMultiplier: 0.7)
    }
    
    private func updateButtonLayout() {
        backButton.round()
        updateGradientLayers()
        updateShadowPath()
    }
    
    private func updateGradientLayers() {
        backButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach {
            $0.frame = backButton.bounds
            $0.cornerRadius = backButton.layer.cornerRadius
        }
    }
    
    private func updateShadowPath() {
        backButton.layer.shadowPath = UIBezierPath(roundedRect: backButton.bounds, cornerRadius: backButton.layer.cornerRadius).cgPath
    }
}
