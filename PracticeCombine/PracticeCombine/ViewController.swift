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
    private var cancelBags = [AnyCancellable]()
    private var list: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.presenter = self
        viewModel.requestAction(with: .viewDidLoad)
        
        testCurrentValueSubject()
        runTimer()
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
        cell.action.sink { [weak self] _ in
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

class TestSubscriptor: Subscription {
    func request(_ demand: Subscribers.Demand) {
        print(">>> TestSubscriptor request \(demand)")
    }
    
    func cancel() {
        print(">>> TestSubscriptor cancel")
    }
}

/// Mark : Private functions
private extension ViewController {
    private func testCurrentValueSubject() {
        let subject = CurrentValueSubject<String, Never>("ABC")
        subject.sink {
            print(">>> currentValueSubject \($0)")
        }
        .store(in: &cancelBags)
        
        subject.value = "DEF"
        subject.send("GHI")
        subject.send(completion: .finished)
        subject.send("XXX")
        testPassthroughSubject()
    }
    
    private func testPassthroughSubject() {
        let subject = PassthroughSubject<String, Error>()
        subject.sink {
            print(">>> passthroughSubject error \($0)")
        } receiveValue: {
            print(">>> passthroughSubject \($0)")
        }
        .store(in: &cancelBags)
        
        subject.send(subscription: TestSubscriptor())
        subject.send("Hello")
        subject.send("World")
        subject.send(completion: .failure(NSError(domain: "", code: -1)))
//        subject.send(completion: .finished)
        subject.send("XXX")
        
        testScheduler()
    }
    
    private func testScheduler() {
        let subject1 = CurrentValueSubject<String, Never>("KKK")
        subject1
            .map { _ in print(">>> subject111 \(Thread.isMainThread)") }
            .receive(on: DispatchQueue.main)
            .map { _ in print(">>> subject122 \(Thread.isMainThread)") }
            .subscribe(on: DispatchQueue.global())
            .sink {
                print(">>> subject133 \($0) isMainThread \(Thread.isMainThread)")
            }
            .store(in: &cancelBags)

        let subject = CurrentValueSubject<String, Never>("Thread")
        subject
            .subscribe(on: DispatchQueue.global())
            .sink {
                print(">>> subject \($0) isMainThread \(Thread.isMainThread)")
            }
            .store(in: &cancelBags)
        
        testCancellable()
    }
    
    private func testCancellable() {
        let subject = PassthroughSubject<String, Error>()
        subject.handleEvents { subscription in
            print(">>> testCancellable subscription11 \(subscription)")
        } receiveOutput: { receiveOutput in
            print(">>> testCancellable receiveOutput33 \(receiveOutput)")
        } receiveCompletion: { receive in
            print(">>> testCancellable receiveCompletion55 \(receive)")
        } receiveCancel: {
            print(">>> testCancellable receiveCancel")
        } receiveRequest: { receiveRequest in
            print(">>> testCancellable receiveRequest22 \(receiveRequest)")
        }
        .sink { type in
            print(">>> testCancellable sink66 \(type)")
        } receiveValue: { receiveValue in
            print(">>> testCancellable receiveValue44 \(receiveValue)")
        }
        .store(in: &cancelBags)
        subject.send("can cancel")
        subject.send(completion: .finished)
        subject.send(completion: .failure(NSError(domain: "cancel", code: -2)))
    }
    
    private func runTimer() {
        let colors: [UIColor] = [.systemRed, .systemOrange, .systemCyan, .systemGray, .systemMint, .systemPink]
        Timer.publish(every: 1.0, on: .main, in: .default)
            .autoconnect() // 이걸 안 해주면 타이머가 동작하지 않음
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.view.backgroundColor = colors.randomElement()
            }
            .store(in: &cancelBags)
    }
}

