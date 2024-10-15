//
//  ActorProfileView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 01/10/2024.
//

import SwiftUI
import MovieListFramework

class ActorProfileStore: ObservableObject {
    @Published var actor: Person?
    
    let presenter: ActorProfilePresenterInputProtocol!
    let actorId: Int
    init(presenter: ActorProfilePresenterInputProtocol, actorId: Int) {
        self.presenter = presenter
        self.actorId = actorId
    }
    func fetchActorDetails() {
        self.presenter.fetchActorDetails(for: actorId)
    }
    
    //to wire
    func buildStoreForDetails(with media: MediaViewModel) -> MediaDetailStore {
        let mediaDetails = MediaTypeID(media.type, media.id)
        let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
        
        let presenter = MediaDetailPresenter(interactor: interactor, router: MediaDetailRouter(), mediaTypeId: mediaDetails)
        interactor.output = presenter
        let store = MediaDetailStore(presenter: presenter, onDismissClosure: nil)
        presenter.output = store
       
        return store
    }
}

extension ActorProfileStore: ActorProfilePresenterOutputProtocol {
    func updateUI() {
        DispatchQueue.main.async {
            self.actor = self.presenter.getViewModel()
        }
    }
}

struct ActorProfileView: View {
    @StateObject var store: ActorProfileStore
    @State var showFullSreen: Bool = false
    @State var bigImage: Image? = nil
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    PhotoAndBioTile(birthday: store.actor?.birthday ?? "", biography: store.actor?.biography ?? "", profilePicturePath: store.actor?.profilePicturePath)
                        .navigationTitle(store.actor?.name ?? "")
                        .padding(.horizontal, 4)
                    
                    ProfileGalleryView(images: store.actor?.images.profiles ?? [], onTapImageClosure: maximizeImage)
                        .padding(.horizontal, 4)
                    
                    MediaAppearances(movies: store.actor?.movieCredits.cast ?? [], job: .cast)//
                        .padding(.horizontal, 4)
                        .padding(.top, 10)
                    
                    MediaAppearances(movies: store.actor?.movieCredits.crew ?? [], job: .crew)//
                        .padding(.horizontal, 4)
                        .padding(.top, 10)
                }
            }
            
            // Fullscreen Image display
            if let bigImage = bigImage {
                Color.black.opacity(0.8) // Background overlay for focus
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    bigImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9) // Image scaling
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding() // Optional padding
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .onTapGesture {
                    // Hide the image when tapped again
                    self.bigImage = nil
                }
            }
        }
        .onAppear {
            store.fetchActorDetails()
        }
    }
    
    func maximizeImage(image: Image) {
        self.bigImage = image
    }
}

struct PhotoAndBioTile: View {
    var birthday: String
    var biography: String
    var profilePicturePath: String?
    var body: some View {
        NavigationLink {
            ScrollView(.vertical) {
                VStack {
                    Text(biography)
                        .font(.body)
                        .padding()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.prussianBlue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 10)
            .navigationTitle("Biography")
        } label: {
            HStack(alignment: .center) {
                CachedAsyncImage(url: URL(string: profilePicturePath ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Image(.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 2.5)
                        ProgressView()
                            .tint(.black)
                    }
                }
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 2.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 14) {
                    Text(biography)
                        .font(.body)
                        .lineLimit(10)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 7)
                    Text("Born: " + birthday)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ProfileGalleryView: View {
    let images: [MediaImage]
    @State var scale: CGFloat = 1
    
    var onTapImageClosure: (Image) -> Void = {_ in }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Gallery")
                .padding([.leading, .top])
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(images.indices, id:\.self) { index in
                        if let url = URL(string: images[index].fullImagePath) {
                            CachedAsyncImage(url: url) { image in
                                image.resizable()
                                    .onTapGesture {
                                        onTapImageClosure(image)
                                        print("HERE")
                                    }
                            } placeholder: {
                                ZStack {
                                    Image(.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                    ProgressView()
                                        .tint(.black)
                                }
                            }
                            .scaledToFit()
                            .frame(width: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom, 0)
                            
                        }
                    }
                }
            }
            
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

enum MediaJob {
    case cast
    case crew
}

struct MediaAppearances: View {
    let movies: [Movie]
    let job: MediaJob
    @State var sortOption: SortingOption = .date
    @State var isAscending: Bool = true
    
    @State var moviesVM: [MediaViewModel] = []


    @State private var isExpanded = false
    @State private var itemsToShow = 0

    @State private var titleText: String = "Starring in:"
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(titleText)
                    .font(.headline)
                    .padding([.leading, .top])
                Button {
                    withAnimation {
                        isExpanded.toggle()
                        itemsToShow = isExpanded ? moviesVM.count : 0
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down.circle" : "chevron.right.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .tint(.primary)
                .padding(.top)
                Spacer()
                SortMenuView(sortOption: $sortOption, isAscending: $isAscending)
                    .padding(.top)
                    .tint(.white)
            }
            let displayedVideos = Array(moviesVM.prefix(itemsToShow))

            ForEach(displayedVideos.indices, id:\.self) { index in
                NavigationLink(destination: MediaDetailView(store: buildStoreForDetails(with: moviesVM[index]), media: moviesVM[index])) {
                    MediaCellListView(media: moviesVM[index])
                }
            }
            
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            updateMoviesVM()
        }
        .onChange(of: sortOption) { sortMedia(with: sortOption) }
        .onChange(of: isAscending) { sortMedia(with: sortOption) }
        .onChange(of: movies) { 
            updateMoviesVM()
            sortMedia(with: sortOption)
        }
    }
    func updateMoviesVM() {
        print("#### movies are \(movies.count)")
        
        var jobCounts: [String: [Movie]] = [:]
        let jobTitles = ["director", "original music composer", "writer", "screenwriter"]

        for job in jobTitles {
            let filteredMovies = movies.filter { $0.job?.lowercased() == job }
            jobCounts[job] = filteredMovies
        }

        // Determine the job with the most movies
        if job == .crew {
            var selectedArea: [Movie] = []
            var maxCount = 0
            var primaryJob = ""

            for (job, filteredMovies) in jobCounts {
                if filteredMovies.count > maxCount {
                    maxCount = filteredMovies.count
                    primaryJob = job
                    selectedArea = filteredMovies
                }
            }

            titleText = "\(primaryJob.capitalized) in:"
            print("#### movies filtered is \(selectedArea.count)")
            
            self.moviesVM = selectedArea.map { MediaViewModel(movie: $0) }
        } else if job == .cast {
            self.moviesVM = movies.map { MediaViewModel(movie: $0) }
        }

        sortMedia(with: .date)
    }

    func sortMedia(with option: SortingOption) {
        switch sortOption {
        case .relevance:
            moviesVM.sort { isAscending ? ($0.popularity > $1.popularity) : ($0.popularity < $1.popularity) }
        case .date:
            moviesVM.sort { isAscending ? ($0.dateAired > $1.dateAired) : ($0.dateAired < $1.dateAired) }
        case .rating:
            moviesVM.sort { isAscending ? ($0.rating > $1.rating) : ($0.rating < $1.rating) }
        case .title:
            moviesVM.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == (isAscending ? .orderedAscending : .orderedDescending) }
        }
    }
    
    func buildStoreForDetails(with media: MediaViewModel) -> MediaDetailStore {
        let mediaDetails = MediaTypeID(media.type, media.id)
        let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
        
        let presenter = MediaDetailPresenter(interactor: interactor, router: MediaDetailRouter(), mediaTypeId: mediaDetails)
        interactor.output = presenter
        let store = MediaDetailStore(presenter: presenter, onDismissClosure: nil)
        presenter.output = store
       
        return store
    }
}

#Preview {
    let actor: Person = .loadMockData()!
    let interactor = ActorProfileInteractor(networkingService: TMDBNetworkingService())
    let presenter = ActorProfilePresenter(interactor: interactor)
    let store = ActorProfileStore(presenter: presenter, actorId: actor.id)
    VStack {
        NavigationStack {
            ActorProfileView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    .preferredColorScheme(.dark)
}


extension Person {
    // Helper function to load the JSON file
    static func loadMockData() -> Person? {
        // Get the URL for the mock JSON file
        guard let url = Bundle.main.url(forResource: "ryanJSON", withExtension: "json") else {
            print("Failed to locate CastCrewMock.json in bundle.")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            
            // Decode the JSON data
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let mediaCredits = try decoder.decode(Person.self, from: data)
            
            return mediaCredits
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch {
            print("error: ", error)
            return nil
            
        }
    }
}
