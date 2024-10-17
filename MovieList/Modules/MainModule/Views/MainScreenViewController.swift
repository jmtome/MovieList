//
//  MainScreenViewController.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

//MARK: - MainScreenViewController
class MainScreenViewController: UIViewController {
    //TODO: - Check if the presenter should be ! or ?
    var presenter: MainScreenPresenterInputProtocol!
    var loadingPresenter: MainScreenPresenterLoadingInputProtocol?
    
    var tableView: UITableView!
    private var dataSource: MainScreenDiffableDataSource?
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        
        let currentTab = tabBarController?.selectedViewController
        print("view will appear current tab is : \(currentTab?.tabBarItem)")
        
        self.tabBarController?.delegate = self
//        if presenter.mediaCount > 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
//        }
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
        let updatedMedia = presenter.getMedia(.search)
        
        currentSnapshot.appendSections(sections)
        currentSnapshot.appendItems(updatedMedia, toSection: sections.first)
        
        dataSource?.defaultRowAnimation = .fade
        
        DispatchQueue.mainAsyncIfNeeded {
            self.dataSource?.apply(currentSnapshot, animatingDifferences: true)
        }
    }
}


//MARK: - Private UI Configuration Methods
extension MainScreenViewController {
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tabBarController?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: MainScreenTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.backgroundColor = .softDark
        tableView.showsVerticalScrollIndicator = false
        
        tableView.sectionHeaderTopPadding = 0
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

        searchController.searchBar.barTintColor = UIColor.blue
        searchController.searchBar.showsScopeBar = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = presenter.searchBarTitle
        searchController.searchBar.delegate = self
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    

    
    private func setupFilterMenu() {
        var menuActions: [UIAction] {
            SortingOption.allCases.map { option in
                UIAction(title: option.title,
                         image: presenter.sortOption.title == option.title ? UIImage(systemName: presenter.isAscending ? "chevron.up" : "chevron.down") : nil ,
                         identifier: UIAction.Identifier(option.identifier),
                         state: presenter.sortOption.title == option.title ? .on : .off,
                         handler: {[weak self] action in
                    guard let self = self else { return }
                    
                    guard presenter.sortOption.title != action.title else {
                        presenter.isAscending = !presenter.isAscending
                        self.presenter.sortMedia(with: option)
                        return
                    }
                    
                    SortingOption.allCases.forEach { category in
                        if action.title == category.title {
                            self.presenter.sortOption = category
                            self.presenter.isAscending = true
                        }
                    }
                    self.presenter.sortMedia(with: option)
                })
            }
        }
        
        let demoMenu = UIMenu(title: "",options: [.displayInline], children: [
            UIDeferredMenuElement.uncached { completion in
                completion(menuActions)
            }
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: demoMenu)
    }
}


//MARK: - Conformance to Delegates and Protocols

//MARK: - Presenter Output Protocol Conformance
//Called by Presenter, Instantiated by MainScreenViewController
extension MainScreenViewController: MainScreenPresenterOutputProtocol {
    func showAlertFavoritedMedia() {
        presentFavoriteAction(added: true)
    }
    
    func showAlertUnfavoritedMedia() {
        presentFavoriteAction(added: false)
    }
    
    func showError(_ error: Error) {
        presentMLAlert(title: "Error", message: "There was an error:\n Raw Error: \(error)\n Localized Description Error: \(error.localizedDescription)", buttonTitle: "Dismiss")
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
        
        let favoriteAction = UIContextualAction(style: .normal, title: "My title" ) { [weak self] (action, view, completionHandler) in
            self?.presenter.handleFavoriteAction(at: indexPath.row)
            completionHandler(true)
        }
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
        
        let image = UIImage(systemName: isFavorite ? "star" : "star.fill", withConfiguration: largeConfig)?
            .withTintColor(.white, renderingMode: .alwaysTemplate)
            .addBackgroundCircle(isFavorite ? .systemRed : .systemGreen)
        
        
        favoriteAction.image = image
        
  
        favoriteAction.backgroundColor = .softDark
        
        favoriteAction.title =  isFavorite ? "Unfavorite" : "Favorite"
        
        actions.append(favoriteAction)
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let loadingPresenter else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > (contentHeight - height)/2 && !loadingPresenter.isLoadingPage() {
            loadingPresenter.viewShouldFetchNewPage()
        }
    }
}

//MARK: - UISearchResultsUpdating Conformance
extension MainScreenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
        let scope = SearchScope(rawValue: searchController.searchBar.selectedScopeButtonIndex) else { return }

        presenter.updateSearchResults(with: query, scope: scope)
        searchController.searchBar.placeholder = presenter.searchBarTitle
    }
}

//MARK: - UISearchBarDelegate Conformance
extension MainScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
}


extension MainScreenViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let currentVC = tabBarController.selectedViewController,
           let currentIndex = tabBarController.tabBar.items?.firstIndex(of: currentVC.tabBarItem),
           let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)  {

            print("previous tab index was :  \(currentIndex)")
            print("new tab selected is :\(selectedIndex)\n")

            if currentIndex == selectedIndex {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
        }
        return true
    }
    
}
