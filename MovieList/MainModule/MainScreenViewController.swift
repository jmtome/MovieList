//
//  MainScreenViewController.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

protocol MainScreenViewProtocol: AnyObject {
    func displayMovies(_ movies: [AnyMedia], for page: Int)
    func displayError(_ message: String)
    
    func didAddMovieToFavorites(movie: AnyMedia)
    func didRemoveMovieFromFavorites(movie: AnyMedia)
    func isFavorite(movie: Movie) -> Bool
}
enum Section: String, Hashable {
    case movies = "Movies"
    case tvshows = "TV Shows"
    case popularMovies = "Popular Movies"
    case popularShows = "Popular Shows"
    case favorites = "Favorites"
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
    
    var displayTitle: String {
        switch self {
        case .movies:
            return "Movies"
        case .series:
            return "Series"
        case .actors:
            return "Actors"
        }
    }
    
    init(_ media: AnyMedia) {
        if let film = media.getBaseType() as? Movie {
            self = .movies
        }
        else if let show = media.getBaseType() as? TVShow {
            self = .series
        }
        else {
            self = .movies
        }
        
    }
    
    var urlAppendix: String {
        switch self {
        case .movies: return "movies"
        case .series: return "tv"
        case .actors: return "person"
        }
    }
    
    var resultType: Codable.Type {
        switch self {
        case .movies: return Movie.self
        case .series: return TVShow.self
        case .actors: return Person.self
        }
    }
}

class MainScreenViewController: UIViewController {
    var presenter: MainScreenPresenterProtocol?
    var tableView: UITableView!
    var searchController: UISearchController!
    var media: [AnyMedia] = []
    
    private var dataSource: MainScreenDiffableDataSource?
    var isLoading = false
    
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
            self.media.sort { $0.voteAverage < $1.voteAverage }
        case .init("rating desc"):
            self.media.sort { $0.voteAverage > $1.voteAverage }
        case .init("title asc") :
            self.media.sort { $0.title > $1.title }
        case .init("title desc") :
            self.media.sort { $0.title < $1.title }
        case .init("relevance asc"):
            self.media.sort { $0.popularity < $1.popularity  }
        case .init("relevance desc"):
            self.media.sort { $0.popularity > $1.popularity   }
        case .init("date asc"):
            self.media.sort { $0.releaseDate < $1.releaseDate }
        case .init("date desc"):
            self.media.sort { $0.releaseDate > $1.releaseDate  }
        default:
            break
        }
        
        updateSnapshot(with: self.media)
    }
    
    var demoMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    func setupFilterMenu() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: UIImage(systemName: "line.3.horizontal.decrease.circle"), primaryAction: nil, menu: demoMenu)
    }
    
    private func loadInitialData() {
        presenter?.viewDidLoad()
    }
    
    func updateSnapshot(with media: [AnyMedia], completion: (() -> Void)? = nil) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, AnyMedia>()
        
        let sections = presenter?.getSections() ?? []
        
        currentSnapshot.appendSections(sections)
        currentSnapshot.appendItems(media, toSection: sections.first)
        
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
        tableView.estimatedRowHeight = UITableView.automaticDimension // Set an estimated row height for better performance
        
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
}

extension MainScreenViewController: MainScreenViewProtocol {
    func isFavorite(movie: Movie) -> Bool {
        false
    }
    
    func didAddMovieToFavorites(movie: AnyMedia) {
        
    }
    
    func didRemoveMovieFromFavorites(movie: AnyMedia) {
        
    }
    
    func displayMovies(_ media: [AnyMedia], for page: Int) {
        if page == 1 {
            self.media = media
        } else {
            self.media = self.media + media
        }
        self.media.sort { $0.popularity > $1.popularity }
        
        updateSnapshot(with: self.media)
    }
    
    func displayError(_ message: String) {
        // Display an error message to the user
    }
}

extension MainScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return media.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notify the presenter that a movie was selected
        
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectMedia(self.media[indexPath.row])
        
    }
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        let minimumRowHeight: CGFloat = 200 // Set your desired minimum row height here
    ////
    //        return max(UITableView.automaticDimension,200)
    //    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = self.presenter else { return nil }
        let movie = media[indexPath.row]
        let isFavorite = presenter.isFavorite(movie: movie)
        
        var actions = [UIContextualAction]()
        
        let favoriteAction = UIContextualAction(style: .normal, title: nil ) { (action, view, completionHandler) in
            
            presenter.handleFavoriteAction(for: movie)
            completionHandler(true)
        }
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
        favoriteAction.image = UIImage(systemName: isFavorite ? "star" : "star.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysTemplate).addBackgroundCircle(isFavorite ? .systemRed : .systemPurple)
        favoriteAction.backgroundColor = .systemBackground
        
        favoriteAction.title =  isFavorite ? "Unfavorite" : "Favorite"
        
        actions.append(favoriteAction)
        
//        favoriteAction.backgroundColor = isFavorite ? .systemTeal : .systemPurple
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > (contentHeight - height)/2 && !(presenter?.isLoadingPage() ?? true) {
            presenter?.viewShouldFetchNewPage()
        }
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
        searchBar.placeholder = "Search \(scope.displayTitle.capitalized)"
        presenter?.viewDidChangeSearchScope(scope)
    }
}

class MainScreenDiffableDataSource: UITableViewDiffableDataSource<Section, AnyMedia> {
    
    // Set Title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return snapshot().sectionIdentifiers[section].rawValue
    }
}
extension UIImage {

    func addBackgroundCircle(_ color: UIColor?) -> UIImage? {

        let circleDiameter = max(size.width * 2, size.height * 2)
        let circleRadius = circleDiameter * 0.5
        let circleSize = CGSize(width: circleDiameter, height: circleDiameter)
        let circleFrame = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        let imageFrame = CGRect(x: circleRadius - (size.width * 0.5), y: circleRadius - (size.height * 0.5), width: size.width, height: size.height)

        let view = UIView(frame: circleFrame)
        view.backgroundColor = color ?? .systemRed
        view.layer.cornerRadius = circleDiameter * 0.5

        UIGraphicsBeginImageContextWithOptions(circleSize, false, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: circleSize)
        let circleImage = renderer.image { ctx in
            view.drawHierarchy(in: circleFrame, afterScreenUpdates: true)
        }

        circleImage.draw(in: circleFrame, blendMode: .normal, alpha: 1.0)
        draw(in: imageFrame, blendMode: .normal, alpha: 1.0)

        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
