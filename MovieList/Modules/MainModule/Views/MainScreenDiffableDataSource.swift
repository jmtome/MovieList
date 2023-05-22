//
//  MainScreenDiffableDataSource.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import UIKit

//MARK: - Custom UITableViewDiffableDataSource so that its sections have titles.
class MainScreenDiffableDataSource: UITableViewDiffableDataSource<Section, MediaViewModel> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return snapshot().sectionIdentifiers[section].rawValue
    }
}
