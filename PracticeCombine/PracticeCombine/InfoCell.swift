//
//  InfoCell.swift
//  PracticeCombine
//
//  Created by nyon on 2022/03/30.
//

import Foundation
import UIKit
import Combine

final class InfoCell: UITableViewCell {
    var cancelBags = [AnyCancellable]()
    var action = PassthroughSubject<Void, Never>()

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var button: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        cancelBags = [AnyCancellable]()
        action = PassthroughSubject<Void, Never>()
        button.removeTarget(self, action: #selector(touchedButton), for: .touchUpInside)
    }
}

extension InfoCell {
    func prepare(with name: String) {
        nameLabel.text = name
        button.addTarget(self, action: #selector(touchedButton), for: .touchUpInside)
    }
}

private extension InfoCell {
    @objc private func touchedButton() {
        action.send(())
    }
}
