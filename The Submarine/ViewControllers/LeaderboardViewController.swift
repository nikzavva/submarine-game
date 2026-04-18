//
//  LeaderboardViewController.swift
//  The Submarine
//
//  Created by Николай Завгородний on 21.07.2025.
//

import UIKit

class LeaderboardViewController: UIViewController, Storyboarded {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var firstTableView: UITableView!
    @IBOutlet private weak var secondTableView: UITableView!
    @IBOutlet private weak var thirdTableVIew: UITableView!
    @IBOutlet private weak var backButton: UIButton!
    
    private lazy var results: RoundResultsData = {
        UserDefaults.standard.loadRoundResults()
    }()
    
    private lazy var resultsSixtySeconds: [RoundResultData] = {
        results.resultsSixtySeconds.sorted {
            $0.currentTime > $1.currentTime && $0.roundNumber > $1.roundNumber
        }
    }()
    
    private lazy var resultsThirtySeconds: [RoundResultData] = {
        results.resultsThirtySeconds.sorted {
            $0.currentTime > $1.currentTime && $0.roundNumber > $1.roundNumber
        }
    }()
    
    private lazy var resultsTenSeconds: [RoundResultData] = {
        results.resultsTenSeconds.sorted {
            $0.currentTime > $1.currentTime && $0.roundNumber > $1.roundNumber
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        setupInitialState()
    }
    
    @IBAction private func showRootVCButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupInitialState() {
        localize()
        setupBackground()
        setupTableViews()
    }
    
    private func localize() {
        titleLabel.text = "Table of records".localize()
        backButton.setTitle("Back".localize(), for: .normal)
    }
    
    private func setupBackground() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "StartBackground")
        imageView.contentMode = .scaleAspectFill
        view.insertSubview(imageView, at: 0)
    }
    
    func setupTableViews() {
        let seconds = "seconds".localize()
        let titles = ["60 \(seconds)", "30 \(seconds)", "10 \(seconds)"]
        let tableViews: [UITableView] = [firstTableView, secondTableView, thirdTableVIew]

        for (table, title) in zip(tableViews, titles) {
            let label = UILabel()
            label.text = title
            label.font = .boldSystemFont(ofSize: 18)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            let header = UIView(frame: CGRect(x: 0, y: 0, width: table.bounds.width, height: 40))
            header.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: header.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
            table.tableHeaderView = header
        }
        
        [firstTableView, secondTableView, thirdTableVIew].forEach { $0.showsVerticalScrollIndicator = false }
    }
}

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case firstTableView:  return resultsSixtySeconds.count
        case secondTableView: return resultsThirtySeconds.count
        case thirdTableVIew:  return resultsTenSeconds.count
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        
        let item: RoundResultData
        
        switch tableView {
        case firstTableView:
            item = resultsSixtySeconds[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell60", for: indexPath) as? Cell60 else { return UITableViewCell() }
            cell.setText("\(formatter.string(from: item.currentTime)) - \(item.roundNumber)")
            return cell
            
        case secondTableView:
            item = resultsThirtySeconds[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell30", for: indexPath) as? Cell30 else { return UITableViewCell() }
            cell.setText("\(formatter.string(from: item.currentTime)) - \(item.roundNumber)")
            return cell
            
        case thirdTableVIew:
            item = resultsTenSeconds[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell10", for: indexPath) as? Cell10 else { return UITableViewCell() }
            cell.setText("\(formatter.string(from: item.currentTime)) - \(item.roundNumber)")
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
