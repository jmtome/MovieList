//
//  FavoritesViewController.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import UIKit

protocol FavoritesViewProtocol: AnyObject {
    func displayFavoriteMedia(_ favorites: [AnyMedia])
    func displayError(_ message: String)
    
    func didRemoveMovieFromFavorites(movie: Movie)

}

class FavoritesViewController: UIViewController, FavoritesViewProtocol {
    
    
    var presenter: FavoritesPresenterProtocol?
    var tableView: UITableView!
    var searchController: UISearchController!

    
    private var dataSource: FavoritesDiffableDataSource?
//    private var dataSource: UITableViewDiffableDataSource<Section, AnyMedia>?

    var favoriteMovies: [AnyMedia] = []
    init(presenter: FavoritesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
        setupSearchController()
        navigationItem.title = "Favorite Media"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    private func setupDataSource() {
        dataSource = FavoritesDiffableDataSource(tableView: tableView) { tableView, indexPath, media in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseIdentifier, for: indexPath) as? MainScreenTableViewCell else {
                fatalError("Failed to dequeue MainScreenTableViewCell")
            }
            
            cell.setup(with: media)
            return cell
        }
    }
    
    func updateSnapshot(with media: [AnyMedia], completion: (()-> Void)? = nil) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, AnyMedia>()
        currentSnapshot.appendSections([.favorites])
        
        currentSnapshot.appendItems(media, toSection: .favorites)
        dataSource?.defaultRowAnimation = .fade
        
        DispatchQueue.main.async {
            self.dataSource?.apply(currentSnapshot, animatingDifferences: false, completion: completion)
        }
    }
    


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.selectedScopeButtonIndex = 0
        presenter?.viewDidChangeSearchScope(.movies)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
//        tableView.dataSource = self
        tableView.dataSource = dataSource
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: MainScreenTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
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
    
    
    // MARK: - FavoritesViewProtocol
    
    func displayFavoriteMedia(_ favorites: [AnyMedia]) {
        // Update the table view with the favorite movies
        
        self.favoriteMovies = favorites
        self.favoriteMovies.sort { $0.voteAverage > $1.voteAverage }
        
        updateSnapshot(with: self.favoriteMovies)
        
    }
    
 
    
    func displayError(_ message: String) {
        // Display an error message to the user
    }

    func didRemoveMovieFromFavorites(movie: Movie) {
        
    }
    
}

extension FavoritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        presenter?.viewDidChangeSearchQuery(query)
    }
}

extension FavoritesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = SearchScope(rawValue: selectedScope) ?? .movies
        searchBar.placeholder = "Search \(scope.displayTitle.capitalized)"
        presenter?.viewDidChangeSearchScope(scope)
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of favorite movies to display in the table view
        return self.favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = self.presenter else { return nil }
        let movie = favoriteMovies[indexPath.row]

        let favoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { (_, _, completionHandler) in
            
            presenter.removeFavoriteMovie(movie)
            self.searchController.searchBar.text = ""
            completionHandler(true)
        }
        favoriteAction.backgroundColor = .systemTeal
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notify the presenter that a favorite movie was selected
    }
    
   
}

class FavoritesDiffableDataSource: UITableViewDiffableDataSource<Section, AnyMedia> {
    
    // Set Title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return snapshot().sectionIdentifiers[section].rawValue
    }
}



//    func updateSnapshot2(with media: [AnyMedia], completion: (() -> Void)? = nil) {
//        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, AnyMedia>()
//        currentSnapshot.appendSections([.movies, .tvshows])
//
//        let movies = media.filter { $0.mediaType() == Movie.self }
//        let series = media.filter { $0.mediaType() == TVShow.self }
//
//        print("nmovies are:\n")
//        movies.forEach { print("movie is \($0)") }
//
//        print("\nseries are:\n")
//        series.forEach { print("serie is \($0)") }
//
//
//        currentSnapshot.appendItems(movies, toSection: .movies)
//        currentSnapshot.appendItems(series, toSection: .tvshows)
//
//        dataSource?.defaultRowAnimation = .fade
//
//        DispatchQueue.main.async {
//            self.dataSource?.apply(currentSnapshot, animatingDifferences: false, completion: completion)
//        }
//    }


    /*
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         guard let presenter = self.presenter else { return nil }
         
         let movies = favoriteMovies.filter { $0.mediaType() == Movie.self }
         let series = favoriteMovies.filter { $0.mediaType() == TVShow.self }
         var movie: AnyMedia = AnyMedia(Movie())
         
         switch indexPath.section {
         case 0:
             movie = movies[indexPath.row]
         case 1:
             movie = series[indexPath.row]
         default :break
         }
         
         favoriteMovies.forEach { print("media title: \($0.title), array position: \(indexPath.row)\n") }
         
         let favoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { (_, _, completionHandler) in
             
             presenter.removeFavoriteMovie(movie)
             completionHandler(true)
         }
         favoriteAction.backgroundColor = .systemTeal
         let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
         return configuration
     }
     */
