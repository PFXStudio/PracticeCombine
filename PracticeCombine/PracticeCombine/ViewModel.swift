//
//  ViewModel.swift
//  PracticeCombine
//
//  Created by nyon on 2022/03/30.
//

import Foundation
import Combine

protocol ViewModelable: AnyObject {
    var service: Serviceable { get }
    var presenter: Presentable? { get set }
    func requestAction(with inputAction: InputAction)
}

enum Output {
    case list([String])
    case indicator(Bool)
    case error(String)
}

protocol Presentable: AnyObject {
    func updateState(with output: Output)
}

final class ViewModel: ViewModelable {
    let service: Serviceable
    weak var presenter: Presentable?
    
    private var cancelBags = [AnyCancellable]()
    private var list: [String] = []

    init(service: Serviceable) {
        self.service = service
    }
}

extension ViewModel {
    func requestAction(with inputAction: InputAction) {
        print(">>> requestAction \(inputAction)")
        switch inputAction {
        case .viewDidLoad:
            fetchCompanyList()
        case let .touchedInfoButton(index):
            let name = list[index]
            print(">>> \(name)")
        }
    }
}

private extension ViewModel {
    private func fetchCompanyList() {
        presenter?.updateState(with: .indicator(true))
        service.fetchCompanies()
            .receive(on: DispatchQueue.main)
            .sink { [weak presenter] completion in
                presenter?.updateState(with: .indicator(false))
                switch completion {
                case let .failure(error):
                    print(">>> error \(error)")
                    presenter?.updateState(with: .error(error.localizedDescription))
                case .finished:
                    print(">>> finished")
                }
            } receiveValue: { [weak self, weak presenter] values in
                self?.list = values
                presenter?.updateState(with: .list(values))
            }
            .store(in: &cancelBags)
    }
}
