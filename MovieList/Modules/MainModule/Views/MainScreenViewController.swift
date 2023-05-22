//
//  MainScreenViewController.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

//MARK: - MainScreenViewController
class MainScreenViewController: UIViewController {
    var presenter: MainScreenPresenterInputProtocol!
    
    var tableView: UITableView!
    private var dataSource: MainScreenDiffableDataSource?
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        setupTableView()
        setupDataSource()
        setupSearchController()
   
        navigationItem.title = presenter.title
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupFilterMenu()
    }
    
    private func updateSnapshot() {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, MediaViewModel>()
        
        let sections = presenter.getSections()
        let updatedMedia = presenter.getMedia()
        
        currentSnapshot.appendSections(sections)
        currentSnapshot.appendItems(updatedMedia, toSection: sections.first)
        
        dataSource?.defaultRowAnimation = .fade
        
        DispatchQueue.mainAsyncIfNeeded {
            self.dataSource?.apply(currentSnapshot, animatingDifferences: false)
        }
    }
}

//MARK: - Presenter Output Protocol Conformance
//Called by Presenter, Instantiated by MainScreenViewController
extension MainScreenViewController: MainScreenPresenterOutputProtocol {
    func showAlertFavoritedMedia() {
        presentMLAlert(title: "Favorites", message: "Media has been added to Favorites", buttonTitle: "Dismiss")
    }
    
    func showAlertUnfavoritedMedia() {
        presentMLAlert(title: "Favorites", message: "Media has been removed from Favorites", buttonTitle: "Dismiss")
    }
    
    func showError(_ error: Error) {
        presentDefaultError()
    }
    
    func updateUIList() {
        updateSnapshot()
    }
}

//MARK: - UITableViewDelegate Conformance
extension MainScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.mediaCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectCell(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isFavorite = presenter.isFavorite(at: indexPath.row)
        var actions = [UIContextualAction]()
        
        let favoriteAction = UIContextualAction(style: .normal, title: nil ) { [weak self] (action, view, completionHandler) in
            self?.presenter.handleFavoriteAction(at: indexPath.row)
            completionHandler(true)
        }
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
        favoriteAction.image = UIImage(systemName: isFavorite ? "star" : "star.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysTemplate).addBackgroundCircle(isFavorite ? .systemTeal : .systemPurple)
        favoriteAction.backgroundColor = .systemBackground
        
        favoriteAction.title =  isFavorite ? "Unfavorite" : "Favorite"
        
        actions.append(favoriteAction)
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > (contentHeight - height)/2 && !presenter.isLoadingPage() {
            presenter.viewShouldFetchNewPage()
        }
    }
}

//MARK: - UISearchResultsUpdating Conformance
extension MainScreenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        presenter.viewDidChangeSearchQuery(query)
    }
}

//MARK: - UISearchBarDelegate Conformance
extension MainScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = SearchScope(rawValue: selectedScope) ?? .movies
        searchBar.placeholder = "Search \(scope.displayTitle.capitalized)"
        presenter.viewDidChangeSearchScope(scope)
    }
}


enum SortingOption: CaseIterable {
    case relevance
    case date
    case rating
    case title
    
    var title: String {
        switch self {
        case .relevance: return "Popularity"
        case .date: return "Date"
        case .rating: return "Rating"
        case .title: return "Name"
        }
    }
    
    var identifier: String {
        return "\(self)"
    }

    var image: UIImage {
        switch self {
        case .relevance: return UIImage(systemName: "arrow.up")!
        case .date: return UIImage(systemName: "arrow.up")!
        case .rating: return UIImage(systemName: "arrow.up")!
        case .title: return UIImage(systemName: "arrow.up")!
        }
    }
    
}


//MARK: - Private UI Methods
extension MainScreenViewController {
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: MainScreenTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupDataSource() {
        dataSource = MainScreenDiffableDataSource(tableView: tableView) { tableView, indexPath, media in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseIdentifier, for: indexPath) as? MainScreenTableViewCell else {
                fatalError("Failed to dequeue MainScreenTableViewCell")
            }
            cell.setup(with: media)
            return cell
        }
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = [SearchScope.movies.displayTitle,
                                                        SearchScope.series.displayTitle]
        searchController.searchBar.showsScopeBar = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupFilterMenu() {
        var menuActions: [UIAction] {
            SortingOption.allCases.map { option in
                UIAction(title: option.title, image: option.image , identifier: UIAction.Identifier(option.identifier), handler: {[weak self] _ in
                    self?.presenter.sortMedia(with: option)
                })
            }
        }
        let demoMenu = UIMenu(title: "",options: [.displayInline], children: menuActions)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: demoMenu)
    }
}
