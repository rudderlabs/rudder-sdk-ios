//
//  ShareSelectViewController.swift
//  ShareExtension
//
//  Created by Desu Sai Venkat on 14/11/23.
//
import UIKit

protocol ShareSelectViewControllerDelegate : AnyObject {
    func selected(event: Event)
}

class ShareSelectViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.Event)
        return tableView
    }()
    weak var delegate: ShareSelectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Select Event"
        view.addSubview(tableView)
    }
}

extension ShareSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Event.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Event, for: indexPath)
        cell.textLabel?.text = Event.allCases[indexPath.row].rawValue
        cell.backgroundColor = .clear
        return cell
    }
}

extension ShareSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(event: Event.allCases[indexPath.row])
    }
}

private extension ShareSelectViewController {
    struct Identifiers {
        static let Event = "event"
    }
}
