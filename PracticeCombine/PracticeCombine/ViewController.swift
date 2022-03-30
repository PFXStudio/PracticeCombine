//
//  ViewController.swift
//  PracticeCombine
//
//  Created by nyon on 2022/03/30.
//

import UIKit
import Combine

enum InputAction {
    case viewDidLoad
    case touchedInfoButton(Int)
}

final class ViewController: UIViewController, Presentable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    private var viewModel: ViewModelable = ViewModel(service: Service())
    private var cancelBag = [AnyCancellable]()
    private var list: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.presenter = self
        viewModel.requestAction(with: .viewDidLoad)
    }
}

/// Mark : public functions
extension ViewController {
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InfoCell.self), for: indexPath) as? InfoCell else {
            return UITableViewCell()
        }
        
        let item = list[indexPath.row]
        cell.prepare(with: item)
        cell.action.sink { _ in
            
        } receiveValue: { [weak self] text in
            self?.viewModel.requestAction(with: .touchedInfoButton(indexPath.row))
        }
        .store(in: &cell.cancelBags)
        
        return cell
    }
    
    func updateState(with output: Output) {
        print(">>> updateState \(output)")
        switch output {
        case let .list(values):
            list = values
            tableView.reloadData()
        case let .indicator(isShow):
            indicatorView.isHidden = !isShow
        case let .error(message):
            print(">>> error message \(message)")
        }
    }
}

/// Mark : Private functions
private extension ViewController {
    
}

