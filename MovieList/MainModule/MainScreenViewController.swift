//
//  MainScreenViewController.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

protocol MainScreenViewProtocol: AnyObject {
    func displayMovies(_ movies: [Movie])
    func displayError(_ message: String)
    
    func didAddMovieToFavorites(movie: Movie)
    func didRemoveMovieFromFavorites(movie: Movie)
    func isFavorite(movie: Movie) -> Bool
}
enum Section {
    case main
}

enum SortingOption: String, CaseIterable {
    case rating = "Rating"
    case date = "Date"
    case relevance = "Relevance"
}

enum SearchScope: Int {
    case movies
    case series
    case actors
    case directors
    
    var displayTitle: String {
        switch self {
        case .movies:
            return "Movies"
        case .series:
            return "Series"
        case .actors:
            return "Actors"
        case .directors:
            return "Directors"
        }
    }
    
    var resultType: Codable.Type {
        switch self {
        case .movies: return Movie.self
        case .series: return TVShow.self
        case .actors, .directors: return Person.self
        }
    }
}

class MainScreenViewController: UIViewController {
    var presenter: MainScreenPresenterProtocol?
    var tableView: UITableView!
    var searchController: UISearchController!
    var movies: [Movie] = []
    private var dataSource: UITableViewDiffableDataSource<Section, Movie>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view
        setupTableView()
        setupDataSource()
        setupSearchController()
        loadInitialData()
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupFilterMenu()
    }

    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Relevance Asc",
                     image: UIImage(systemName: "star.fill"),
                     identifier: .init("relevance asc"),
                     discoverabilityTitle: nil,
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Relevance Desc",
                     image: UIImage(systemName: "star"),
                     identifier: .init("relevance desc"),
                     discoverabilityTitle: nil,
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Title Asc",
                     image: UIImage(systemName: "text.insert"),
                     identifier: .init("title asc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Title Desc",
                     image: UIImage(systemName: "text.append"),
                     identifier: .init("title desc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Rating Asc",
                     image: UIImage(systemName: "text.insert"),
                     identifier: .init("rating asc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Rating Desc",
                     image: UIImage(systemName: "text.append"),
                     identifier: .init("rating desc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Date Asc",
                     image: UIImage(systemName: "text.insert"),
                     identifier: .init("date asc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:)),
            UIAction(title: "Date Desc",
                     image: UIImage(systemName: "text.append"),
                     identifier: .init("date desc"),
                     attributes: .keepsMenuPresented,
                     handler: sortResults(_:))
        ]
    }
    
    //refactor this
    func sortResults(_ action: UIAction) {
        switch action.identifier {
        case .init(.init("rating asc")):
            self.movies.sort { $0.voteAverage ?? 0.0 < $1.voteAverage ?? 0.0  }
        case .init("rating desc"):
            self.movies.sort { $0.voteAverage ?? 0.0  > $1.voteAverage ?? 0.0  }
        case .init("title asc") :
            self.movies.sort { $0.title ?? "" > $1.title ?? "" }
        case .init("title desc") :
            self.movies.sort { $0.title ?? "" < $1.title ?? "" }
        case .init("relevance asc"):
            self.movies.sort { $0.popularity ?? 0.0 < $1.popularity ?? 0.0 }
        case .init("relevance desc"):
            self.movies.sort { $0.popularity ?? 0.0  > $1.popularity ?? 0.0  }
        case .init("date asc"):
            self.movies.sort { $0.releaseDate ?? "" < $1.releaseDate ?? "" }
        case .init("date desc"):
            self.movies.sort { $0.releaseDate ?? "" > $1.releaseDate ?? "" }
        default:
            break
        }
        
        updateSnapshot(with: self.movies)
        
    }
    
    var demoMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    func setupFilterMenu() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: UIImage(systemName: "line.3.horizontal.decrease.circle"), primaryAction: nil, menu: demoMenu)
    }

    
    private func loadInitialData() {
        
        //pop data
        presenter?.viewDidLoad()
        
//        searchController.searchBar.text = "Matrix"
//        updateSearchResults(for: searchController)
    }
    //
    func updateSnapshot(with movies: [Movie], completion: (() -> Void)? = nil) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(movies, toSection: .main)
        
        dataSource?.defaultRowAnimation = .fade
        
        DispatchQueue.main.async {
            self.dataSource?.apply(currentSnapshot, animatingDifferences: false, completion: completion)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        //        tableView.dataSource = self
        tableView.dataSource = dataSource
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: MainScreenTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50 // Set an estimated row height for better performance
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Movie>(tableView: tableView) { tableView, indexPath, movie in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseIdentifier, for: indexPath) as? MainScreenTableViewCell else {
                fatalError("Failed to dequeue MainScreenTableViewCell")
            }
            cell.setup(with: movie)
            return cell
        }
        //        dataSource?.defaultRowAnimation = .bottom
        
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = [SearchScope.movies.displayTitle,
                                                        SearchScope.series.displayTitle,
                                                        SearchScope.actors.displayTitle,
                                                        SearchScope.directors.displayTitle]
        searchController.searchBar.showsScopeBar = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
}

extension MainScreenViewController: MainScreenViewProtocol {
    func isFavorite(movie: Movie) -> Bool {
        false
    }
    
    func didAddMovieToFavorites(movie: Movie) {
        
    }
    
    func didRemoveMovieFromFavorites(movie: Movie) {
        
    }
    
    func displayMovies(_ movies: [Movie]) {
        self.movies = movies
        self.movies.sort { $0.voteAverage ?? 0.0  > $1.voteAverage ?? 0.0  }
        
        updateSnapshot(with: self.movies)
    }
    
    func displayError(_ message: String) {
        // Display an error message to the user
    }
}

extension MainScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of movies to display in the table view
        return movies.count
    }
    
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainScreenTableViewCell
    //        cell.setup(with: self.movies[indexPath.row])
    //        return cell
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notify the presenter that a movie was selected
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minimumRowHeight: CGFloat = 150 // Set your desired minimum row height here
        
        return max(tableView.rowHeight, minimumRowHeight)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = self.presenter else { return nil }
        let movie = movies[indexPath.row]
        let isFavorite = presenter.isFavorite(movie: movie)
        let favoriteAction = UIContextualAction(style: .normal, title: isFavorite ? "Unfavorite" : "Favorite") { (_, _, completionHandler) in
            
            presenter.handleFavoriteAction(for: movie)
            completionHandler(true)
        }
        favoriteAction.backgroundColor = isFavorite ? .systemTeal : .systemPurple
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        return configuration
    }
}

extension MainScreenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        presenter?.viewDidChangeSearchQuery(query)
    }
}

extension MainScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = SearchScope(rawValue: selectedScope) ?? .movies
        presenter?.viewDidChangeSearchScope(scope)
    }
}
