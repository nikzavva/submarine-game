//
//  GameViewController.swift
//  The Submarine
//
//  Created by Николай Завгородний on 21.07.2025.
//

import UIKit

class GameViewController: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet private weak var mainGameView: UIView!
    @IBOutlet private var submarinePlaces: [UIView]!
    @IBOutlet private weak var oxygenWestTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var surfaceView: UIView!
    @IBOutlet private weak var middleView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var attackButton: UIButton!
    @IBOutlet private weak var timerView: UIView!
    @IBOutlet private weak var roundCountView: UIView!
    
    // MARK: - Properties
    private lazy var submarineImageView: UIImageView = createSubmarineImageView()
    private lazy var timerLabel: UILabel = timerView.createLabel()
    private lazy var roundCountLabel: UILabel = roundCountView.createLabel()
    
    private var settings: SettingsData = {
        UserDefaults.standard.loadSettings() ?? SettingsData(name: nil, submarineIndex: 0, speedIndex: 0)
    }()
    
    private var submarineImageName: String {
        SubmarineImage(rawValue: settings.submarineIndex)?.assetName ?? "Submarine"
    }
    
    private var roundDurationSeconds: Int {
        RoundDuration(rawValue: settings.speedIndex)?.maxSeconds ?? 60
    }
    
    private var currentOxygenAnimator: UIViewPropertyAnimator?
    private var oxygenWestSpeed: TimeInterval = 10
    private let minOxygenWestSpeed: TimeInterval = 2
    private var isOxygenDepleting = false
    
    private var placesCenters = [CGPoint]()
    private var currentPlaceIndex = 2
    
    private var enemies = [Enemy]()
    private var spawnTimer: Timer?
    private var spawnInterval: TimeInterval = 3
    private var enemyStepSpeed: CGFloat = 3
    private let maxEnemyStepSpeed: CGFloat  = 10
    
    private let torpedoSideMultiplier = 0.7
    private let maxTorpedoCount = 3
    private var currentTorpedosCount = 3
    private let torpedoStepSpeed: CGFloat = 7
    
    private var roundTimer: Timer?
    private var currentRoundSeconds = 0
    private var currentRoundCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        setupInitialState()
    }
    
    // MARK: - Actions
    @IBAction private func upButtonPressed(_ sender: UIButton) {
        moveSubmarine(by: .up)
    }
    
    @IBAction private func downButtonPressed(_ sender: UIButton) {
        moveSubmarine(by: .down)
    }
    
    @IBAction private func attackButtonPressed(_ sender: UIButton) {
        fireTorpedo()
    }
    
    // MARK: - Setup Methods
    private func setupInitialState() {
        setupView()
        setupPlacesCenters()
        positionSubmarine()
        setupAttackButtonText()
        startEnemySpawning()
        setupTimerLabels()
        startNewRoundTimer()
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "GameBackground")
        imageView.contentMode = .scaleAspectFill
        view.insertSubview(imageView, at: 0)
    }
    
    private func createSubmarineImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: submarineImageName))
        guard let image = imageView.image else { return imageView }

        let place = submarinePlaces[currentPlaceIndex]
        let scale = min(place.frame.width / image.size.width, place.frame.height / image.size.height)

        imageView.frame.size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        mainGameView.addSubview(imageView)
        return imageView
    }
    
    private func setupTimerLabels() {
        timerLabel.setText("\(roundDurationSeconds)")
        roundCountLabel.setText("\(currentRoundCount)")
    }
    
    private func setupPlacesCenters() {
        placesCenters = submarinePlaces
            .map { mainGameView.convert($0.center, from: $0.superview) }
            .sorted { $0.x < $1.x }
    }
    
    private func positionSubmarine() {
        submarineImageView.center = placesCenters[currentPlaceIndex]
    }
    
    private func setupAttackButtonText() {
        changeButtonTorpedosCount(by: .recovery)
    }
    
    // MARK: - Submarine Movement Logic
    private func moveSubmarine(by direction: MoveDirection) {
        guard let newIndex = newIndex(for: direction) else { return }
        currentPlaceIndex = newIndex
        
        animateSubmarineMovement(to: placesCenters[newIndex])
        handleOxygenState(for: newIndex)
    }
    
    private func newIndex(for direction: MoveDirection) -> Int? {
        switch direction {
        case .up where currentPlaceIndex < placesCenters.count - 1:
            return currentPlaceIndex + 1
        case .down where currentPlaceIndex > 0:
            return currentPlaceIndex - 1
        default:
            return nil
        }
    }
    
    private func animateSubmarineMovement(to position: CGPoint) {
        UIView.animate(withDuration: 0.3) {
            self.submarineImageView.center = position
        }
    }
    
    // MARK: - Oxygen West Logic
    private func handleOxygenState(for index: Int) {
        if index != placesCenters.count - 1 {
            startOxygenDepletion()
        } else {
            startOxygenReplenish()
        }
    }
    
    private func startOxygenDepletion() {
        guard !isOxygenDepleting else { return }
        isOxygenDepleting = true
        
        currentOxygenAnimator?.stopAnimation(true)
        
        animateOxygenChange(
            duration: oxygenWestSpeed,
            targetConstant: view.frame.maxY,
            completion: {
                self.roundTimer?.invalidate()
                self.endGame()
            }
        )
    }
    
    private func startOxygenReplenish() {
        currentOxygenAnimator?.stopAnimation(true)
        isOxygenDepleting = false
        
        animateOxygenChange(
            duration: 0.3,
            targetConstant: 0
        )
    }
    
    private func animateOxygenChange(duration: TimeInterval, targetConstant: CGFloat, completion: (() -> Void)? = nil) {
        currentOxygenAnimator = UIViewPropertyAnimator(
            duration: duration,
            curve: .linear
        ) {
            self.oxygenWestTopConstraint.constant = targetConstant
            self.view.layoutIfNeeded()
        }
        
        currentOxygenAnimator?.addCompletion { _ in
            completion?()
        }
        
        currentOxygenAnimator?.startAnimation()
    }
    
    // MARK: - Enemies Logic
    private func startEnemySpawning() {        
        let enemyTypes: [(String, UIView)] = [
            ("Ship", surfaceView),
            ("Shark", middleView),
            ("Rock", bottomView)
        ]
        
        spawnRandomEnemies(from: enemyTypes, count: 1)
        scheduleNextRandomSpawn(enemyTypes: enemyTypes)
    }

    private func scheduleNextRandomSpawn(enemyTypes: [(String, UIView)]) {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: false) { [weak self] _ in
            self?.spawnRandomEnemies(from: enemyTypes)
            self?.scheduleNextRandomSpawn(enemyTypes: enemyTypes)
        }
    }
    
    private func spawnRandomEnemies(from enemyTypes: [(String, UIView)], count: Int = 2) {
        let selected = (0..<count).compactMap { _ in enemyTypes.randomElement() }
        let grouped = Dictionary(grouping: selected, by: { $0.0 })
        let unique = grouped.values.compactMap { $0.first }
        
        unique.forEach { name, container in
            createAndMoveEnemy(name: name, in: container)
        }
    }
    
    private func createAndMoveEnemy(name: String, in view: UIView) {
        let enemyView = createEnemyImageView(name: name, in: view)
        mainGameView.addSubview(enemyView)
        
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self else {
                timer?.invalidate()
                return
            }
            
            enemyView.frame.origin.x -= enemyStepSpeed
            
            if submarineImageView.frame.intersects(enemyView.frame) {
                remove(enemy: enemyView)
                roundTimer?.invalidate()
                endGame()
                return
            }
            
            if enemyView.frame.maxX < 0 {
                remove(enemy: enemyView)
                return
            }
        }
        
        enemies.append(Enemy(view: enemyView, timer: timer))
    }
    
    private func createEnemyImageView(name: String, in view: UIView) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: name))
        guard let image = imageView.image else { return imageView }

        let maxHeight = view.bounds.height
        let aspect = image.size.width / image.size.height
        let newWidth = maxHeight * aspect

        imageView.frame.size = CGSize(width: newWidth, height: maxHeight)
        imageView.center.y = view.frame.midY
        imageView.frame.origin.x = mainGameView.frame.maxX

        return imageView
    }
    
    private func remove(enemy enemyView: UIImageView) {
        guard let index = enemies.firstIndex(where: { $0.view === enemyView }) else { return }
        enemies[index].timer?.invalidate()
        enemies[index].view.removeFromSuperview()
        enemies.remove(at: index)
    }
    
    // MARK: - Torpedo Logic
    private func fireTorpedo() {
        guard currentTorpedosCount > 0 else { return }
        moveTorpedoImageView()
        changeButtonTorpedosCount(by: .minus)
    }
    
    private func moveTorpedoImageView() {
        let torpedo = createTorpedoImageView()
        mainGameView.insertSubview(torpedo, belowSubview: submarineImageView)
        
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [weak self] _ in
            guard let self else {
                timer?.invalidate()
                return
            }
            
            torpedo.frame.origin.x += torpedoStepSpeed
            
            for enemy in enemies {
                if torpedo.frame.intersects(enemy.view.frame) {
                    torpedo.removeFromSuperview()
                    timer?.invalidate()
                    remove(enemy: enemy.view)
                    return
                }
            }
            
            if torpedo.frame.maxX > mainGameView.frame.maxX + torpedo.frame.width {
                torpedo.removeFromSuperview()
                timer?.invalidate()
            }
        })
    }
    
    private func createTorpedoImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "Torpedo"))
        let side = submarineImageView.frame.height * torpedoSideMultiplier
        imageView.frame.size = CGSize(width: side, height: side)
        imageView.center = submarineImageView.center
        return imageView
    }
    
    private func changeButtonTorpedosCount(by action: TorpedoCountAction) {
        switch action {
        case .minus:
            currentTorpedosCount -= 1
        case .recovery:
            currentTorpedosCount = maxTorpedoCount
        }
        attackButton.setTitle("\(currentTorpedosCount)")
    }
    
    // MARK: - Timer Rounds Logic
    private func startNewRoundTimer() {
        resetRoundTimer()
        startCountdown()
    }

    private func resetRoundTimer() {
        currentRoundSeconds = roundDurationSeconds
        timerLabel.setText("\(currentRoundSeconds)")
    }

    private func startCountdown() {
        roundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            guard currentRoundSeconds > 1 else {
                handleRoundEnd()
                return
            }
            
            currentRoundSeconds -= 1
            timerLabel.setText("\(currentRoundSeconds)")
        }
    }

    private func handleRoundEnd() {
        roundTimer?.invalidate()
        currentRoundCount += 1
        roundCountLabel.setText("\(currentRoundCount)")
        changeButtonTorpedosCount(by: .recovery)
        handleComplication()
        startNewRoundTimer()
    }
    
    private func handleComplication() {
        let baseEnemySpeed: CGFloat = 3.0
        let baseSpawnInterval: TimeInterval = 3.0
        let minSpawnInterval: TimeInterval = 1.0
        
        enemyStepSpeed = min(baseEnemySpeed + CGFloat(currentRoundCount) * 0.2, maxEnemyStepSpeed)
        oxygenWestSpeed = max(10 - TimeInterval(currentRoundCount) * 0.3, minOxygenWestSpeed)
        spawnInterval = max(baseSpawnInterval * (baseEnemySpeed / enemyStepSpeed), minSpawnInterval)
    }
    
    // MARK: - General Methods
    private func endGame() {
        showEndGameView()
        saveResults()
        stopAll()
    }
    
    private func showEndGameView() {
        guard let endGameView = EndGameView.instanceFromNib() else { return }
        endGameView.frame = view.bounds
        endGameView.goBack = { [weak self] in self?.navigationController?.popToRootViewController(animated: true) }
        endGameView.setResultText("Result: ".localize() + "\(currentRoundCount)")
        endGameView.alpha = 0
        view.addSubview(endGameView)

        UIView.animate(withDuration: 0.3) {
            endGameView.alpha = 1
        }
    }
    
    private func saveResults() {
        var all = UserDefaults.standard.loadRoundResults()
        let result = RoundResultData(roundNumber: currentRoundCount, currentTime: Date())

        switch roundDurationSeconds {
        case 60:  all.resultsSixtySeconds.append(result)
        case 30:  all.resultsThirtySeconds.append(result)
        case 10:  all.resultsTenSeconds.append(result)
        default:  break
        }

        UserDefaults.standard.saveRoundResults(all)
    }

    private func stopAll() {
        roundTimer?.invalidate()
        roundTimer = nil
        
        enemies.forEach { $0.timer?.invalidate() }
        enemies.removeAll()

        spawnTimer?.invalidate()
        spawnTimer = nil
        
        currentOxygenAnimator?.stopAnimation(true)
        currentOxygenAnimator = nil
        oxygenWestTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Structs
private struct Enemy {
    let view: UIImageView
    let timer: Timer?
}

// MARK: - Enums
private enum MoveDirection {
    case up, down
}

private enum TorpedoCountAction {
    case minus, recovery
}

private enum SubmarineImage: Int {
    case yellow = 0
    case purple = 1
    case red = 2
    
    var assetName: String {
        switch self {
        case .yellow: return "Submarine"
        case .purple: return "SubmarinePurple"
        case .red: return "SubmarineRed"
        }
    }
}

private enum RoundDuration: Int {
    case slow = 0
    case medium = 1
    case fast = 2
    
    var maxSeconds: Int {
        switch self {
        case .slow: return 60
        case .medium: return 30
        case .fast: return 10
        }
    }
}
