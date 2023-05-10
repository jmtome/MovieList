//
//  FavoritesViewController.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import UIKit

protocol FavoritesViewProtocol: AnyObject {
    func displayFavorites(_ favorites: [Movie])
    func displayError(_ message: String)
    
    func didRemoveMovieFromFavorites(movie: Movie)

}

class FavoritesViewController: UIViewController, FavoritesViewProtocol {
    
    
    var presenter: FavoritesPresenterProtocol?
    var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Movie>?

    var favoriteMovies: [Movie] = []
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
        navigationItem.title = "Favorite Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getFavoriteMovies()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
//        tableView.dataSource = self
        tableView.dataSource = dataSource
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: MainScreenTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
    }
    
    // MARK: - FavoritesViewProtocol
    
    func displayFavorites(_ favorites: [Movie]) {
        // Update the table view with the favorite movies
        self.favoriteMovies = favorites
        self.favoriteMovies.sort { $0.voteAverage ?? 0.0 > $1.voteAverage ?? 0.0}
        
        
        updateSnapshot(with: self.favoriteMovies) {
            DispatchQueue.main.async { [weak self] in
//                self?.tableView.performBatchUpdates(nil, completion: nil)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func updateSnapshot(with movies: [Movie], completion: (() -> Void)?) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(movies, toSection: .main)
        
        dataSource?.defaultRowAnimation = .fade
        
        dataSource?.apply(currentSnapshot, animatingDifferences: false, completion: completion)
    }
    
    func displayError(_ message: String) {
        // Display an error message to the user
    }

    func didRemoveMovieFromFavorites(movie: Movie) {
        
    }
    
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of favorite movies to display in the table view
        return self.favoriteMovies.count
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseIdentifier, for: indexPath) as! MainScreenTableViewCell
//        // Configure the cell with the favorite movie
//        cell.setup(with: self.favoriteMovies[indexPath.row])
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = self.presenter else { return nil }
        let movie = favoriteMovies[indexPath.row]

        let favoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { (_, _, completionHandler) in
            
            presenter.removeFavoriteMovie(movie)
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
