import Foundation

enum MediaCategory {
    case recentlyViewed
    case lastSearch
    case search
    case nowPlaying
    case popular
    case upcoming
    case topRated
    case trending
    
    func title() -> String {
        switch self {
        case .search:
            "Search"
        case .nowPlaying:
            "Now Playing"
        case .popular:
            "Popular"
        case .upcoming:
            "Upcoming"
        case .topRated:
            "All Time Top"
        case .trending:
            "Trending"
        case .recentlyViewed:
            "Recently Viewed"
        case .lastSearch:
            "Last Search"
        }
    }
}