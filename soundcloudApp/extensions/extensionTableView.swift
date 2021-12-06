//
//  extensionTableView.swift
//  soundcloudApp
//
//  Created by pioner on 29.10.2021.
//

import UIKit

extension UITableView {
    func deselectAllRows(animated: Bool) {
        guard let selectedRows = indexPathsForSelectedRows else { return }
        for indexPath in selectedRows { deselectRow(at: indexPath, animated: animated) }
    }
}
