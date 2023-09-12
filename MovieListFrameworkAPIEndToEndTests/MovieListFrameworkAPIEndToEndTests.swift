//
//  MovieListFrameworkAPIEndToEndTests.swift
//  MovieListFrameworkAPIEndToEndTests
//
//  Created by macbook on 11/09/2023.
//

import XCTest
import MovieListFramework
final class MovieListFrameworkAPIEndToEndTests: XCTestCase {
    
    
    func test_endToEndServerGETMediaResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 20, "Expected 20 items in the test account of media items")
            
            items.enumerated().forEach { index, item in
                XCTAssertEqual(item, expectedItems(at: index), "Unexpected item values at index: \(index)")
            }
            
        case let .failure(error)?:
            XCTFail("Expected successful media items result, got \(error) instead.")
        default:
            XCTFail("Expected successful media result, got no result instead")
        }
    }
    
    //MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadMediaResult? {
        let testServerURL = URL(string: "https://gist.githubusercontent.com/jmtome/f09b007a6e46ae91148372a296e8c30d/raw/52267abea83aec0014db7388678e513695e8b6c2/E2ETestApiTMDB.json")!
        let client = URLSessionHTTPClient()
        let loader = RemoteMediaLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadMediaResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
    
    private func expectedItems(at index: Int) -> MediaItem {
        return MediaItem(adult: adult(at: index),
                         backdropPath: backdropPath(at: index),
                         genreIds: genreIds(at: index),
                         id: id(at: index),
                         mediaType: mediaType(at: index),
                         originalLanguage: originalLanguage(at: index),
                         originalTitle: originalTitle(at: index),
                         overview: overview(at: index),
                         popularity: popularity(at: index),
                         posterPath: posterPath(at: index),
                         releaseDate: releaseDate(at: index),
                         title: title(at: index),
                         video: video(at: index),
                         voteAverage: voteAverage(at: index),
                         voteCount: voteCount(at: index))
    }
    
    private func adult(at index: Int) -> Bool {
        return [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
        ][index]
    }
    private func backdropPath(at index: Int) -> String? {
        return [
            "/8pjWz2lt29KyVGoq1mXYu6Br7dE.jpg",
            "/ctMserH8g2SeOAnCw5gFjdQF8mo.jpg",
            "/53z2fXEKfnNg2uSOPss2unPBGX1.jpg",
            "/9m161GawbY3cWxe6txd1NOHTjd0.jpg",
            "/4fLZUr1e65hKPPVw0R3PmKFKxj1.jpg",
            "/2ii07lSwHarg0gWnJoCYL3Gyd1j.jpg",
            "/w2nFc2Rsm93PDkvjY4LTn17ePO0.jpg",
            "/waBWlJlMpyFb7STkFHfFvJKgwww.jpg",
            "/2QL5j6mB4ZpyBcVr0WO9H9MQGBu.jpg",
            "/2vFuG6bWGyQUzYS9d69E5l85nIz.jpg",
            "/4HodYYKEIsGOdinkGi2Ucz6X9i0.jpg",
            "/qEm4FrkGh7kGoEiBOyGYNielYVc.jpg",
            "/fgsHxz21B27hOOqQBiw9L6yWcM7.jpg",
            "/yF1eOkaYvwiORauRCPWznV9xVvi.jpg",
            "/4XM8DUTQb3lhLemJC51Jx4a2EuA.jpg",
            "/xVMtv55caCEvBaV83DofmuZybmI.jpg",
            "/AeR5k8Sp3zc2Ql4tT6CmgqspsEq.jpg",
            "/3mrli3xsGrAieQks7KsBUm2LpCg.jpg",
            "/hPcP1kv6vrkRmQO3YgV1H97FE5Q.jpg",
            "/65rFnxzirxQDM0rYWmtAUYnjc.jpg",
        ][index]
    }
    private func genreIds(at index: Int) -> [Int] {
        return [
            [28, 878, 27],
            [35, 12, 14],
            [27, 9648, 53],
            [12, 28, 14],
            [16, 35, 10751, 14, 10749],
            [35, 12],
            [16, 35, 28],
            [28, 18],
            [28, 12, 18, 14, 36],
            [28, 12, 878],
            [16, 28, 12],
            [27, 14],
            [27, 9648, 53],
            [28, 12, 878],
            [28, 80, 53],
            [53, 28],
            [12, 10751, 14, 10749],
            [28, 80, 53],
            [27, 9648, 53],
            [27, 53],
        ][index]
    }
    private func id(at index: Int) -> Int {
        return [
            615656,
            346698,
            968051,
            335977,
            976573,
            912908,
            614930,
            678512,
            734253,
            667538,
            569094,
            635910,
            439079,
            298618,
            385687,
            724209,
            447277,
            979275,
            614479,
            1094713,
        ][index]
    }
    private func mediaType(at index: Int) -> String? {
        return nil
    }
    private func originalLanguage(at index: Int) -> String {
        return [
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "hi",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
            "en",
        ][index]
    }
    private func originalTitle(at index: Int) -> String {
        return [
            "Meg 2: The Trench",
            "Barbie",
            "The Nun II",
            "Indiana Jones and the Dial of Destiny",
            "Elemental",
            "Strays",
            "Teenage Mutant Ninja Turtles: Mutant Mayhem",
            "Sound of Freedom",
            "आदिपुरुष",
            "Transformers: Rise of the Beasts",
            "Spider-Man: Across the Spider-Verse",
            "The Last Voyage of the Demeter",
            "The Nun",
            "The Flash",
            "Fast X",
            "Heart of Stone",
            "The Little Mermaid",
            "Mob Land",
            "Insidious: The Red Door",
            "The Mistress",
        ][index]
    }
    private func overview(at index: Int) -> String {
        return [
            "An exploratory dive into the deepest depths of the ocean of a daring research team spirals into chaos when a malevolent mining operation threatens their mission and forces them into a high-stakes battle for survival.",
            "Barbie and Ken are having the time of their lives in the colorful and seemingly perfect world of Barbie Land. However, when they get a chance to go to the real world, they soon discover the joys and perils of living among humans.",
            "In 1956 France, a priest is violently murdered, and Sister Irene begins to investigate. She once again comes face-to-face with a powerful evil.",
            "Finding himself in a new era, and approaching retirement, Indy wrestles with fitting into a world that seems to have outgrown him. But as the tentacles of an all-too-familiar evil return in the form of an old rival, Indy must don his hat and pick up his whip once more to make sure an ancient and powerful artifact doesn't fall into the wrong hands.",
            "In a city where fire, water, land and air residents live together, a fiery young woman and a go-with-the-flow guy will discover something elemental: how much they have in common.",
            "When Reggie is abandoned on the mean city streets by his lowlife owner, Doug, Reggie is certain that his beloved owner would never leave him on purpose. But once Reggie falls in with Bug, a fast-talking, foul-mouthed stray who loves his freedom and believes that owners are for suckers, Reggie finally realizes he was in a toxic relationship and begins to see Doug for the heartless sleazeball that he is.",
            "After years of being sheltered from the human world, the Turtle brothers set out to win the hearts of New Yorkers and be accepted as normal teenagers through heroic acts. Their new friend April O'Neil helps them take on a mysterious crime syndicate, but they soon get in over their heads when an army of mutants is unleashed upon them.",
            "The story of Tim Ballard, a former US government agent, who quits his job in order to devote his life to rescuing children from global sex traffickers.",
            "7000 years ago, Ayodhya's Prince Raghava and Prince Sesh along with the Mighty Vanar Warriors travels to the island of Lanka with an aim to rescue Raghava's wife Janaki, who has been abducted by Lankesh, the king of Lanka.",
            "When a new threat capable of destroying the entire planet emerges, Optimus Prime and the Autobots must team up with a powerful faction known as the Maximals. With the fate of humanity hanging in the balance, humans Noah and Elena will do whatever it takes to help the Transformers as they engage in the ultimate battle to save Earth.",
            "After reuniting with Gwen Stacy, Brooklyn’s full-time, friendly neighborhood Spider-Man is catapulted across the Multiverse, where he encounters the Spider Society, a team of Spider-People charged with protecting the Multiverse’s very existence. But when the heroes clash on how to handle a new threat, Miles finds himself pitted against the other Spiders and must set out on his own to save those he loves most.",
            "The crew of the merchant ship Demeter attempts to survive the ocean voyage from Carpathia to London as they are stalked each night by a merciless presence onboard the ship.",
            "A priest with a haunted past and a novice on the threshold of her final vows are sent by the Vatican to investigate the death of a young nun in Romania and confront a malevolent force in the form of a demonic nun.",
            "When his attempt to save his family inadvertently alters the future, Barry Allen becomes trapped in a reality in which General Zod has returned and there are no Super Heroes to turn to. In order to save the world that he is in and return to the future that he knows, Barry's only hope is to race for his life. But will making the ultimate sacrifice be enough to reset the universe?",
            "Over many missions and against impossible odds, Dom Toretto and his family have outsmarted, out-nerved and outdriven every foe in their path. Now, they confront the most lethal opponent they've ever faced: A terrifying threat emerging from the shadows of the past who's fueled by blood revenge, and who is determined to shatter this family and destroy everything—and everyone—that Dom loves, forever.",
            "An intelligence operative for a shadowy global peacekeeping agency races to stop a hacker from stealing its most valuable — and dangerous — weapon.",
            "The youngest of King Triton’s daughters, and the most defiant, Ariel longs to find out more about the world beyond the sea, and while visiting the surface, falls for the dashing Prince Eric. With mermaids forbidden to interact with humans, Ariel makes a deal with the evil sea witch, Ursula, which gives her a chance to experience life on land, but ultimately places her life – and her father’s crown – in jeopardy.",
            "A sheriff tries to keep the peace when a desperate family man violently robs a pill mill with his brother-in-law, alerting an enforcer for the New Orleans mafia.",
            "To put their demons to rest once and for all, Josh Lambert and a college-aged Dalton Lambert must go deeper into The Further than ever before, facing their family's dark past and a host of new and more horrifying terrors that lurk behind the red door.",
            "Newlyweds Parker and Madeline move into their dream home. As they settle in, they discover a box of old love letters written to the original owner. And as the couple digs into the increasingly obsessive correspondence, a mysterious woman arrives with a horrifying secret that threatens their lives.",
        ][index]
    }
    private func popularity(at index: Int) -> Double {
        return [
            5133.953,
            3712.487,
            2536.981,
            2446.673,
            1890.803,
            1873.846,
            1463.597,
            1363.068,
            1227.397,
            1227.346,
            1144.897,
            1097.795,
            1090.173,
            1064.017,
            1048.15,
            968.223,
            938.058,
            835.001,
            743.408,
            712.045,
        ][index]
    }
    private func posterPath(at index: Int) -> String? {
        return [
            "/4m1Au3YkjqsxF8iwQy0fPYSxE0h.jpg",
            "/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg",
            "/5gzzkR7y3hnY8AD1wXjCnVlHba5.jpg",
            "/Af4bXE63pVsb2FtbW8uYIyPBadD.jpg",
            "/6oH378KUfCEitzJkm07r97L0RsZ.jpg",
            "/n1hqbSCtyBAxaXEl1Dj3ipXJAJG.jpg",
            "/ueO9MYIOHO7M1PiMUeX74uf8fB9.jpg",
            "/kSf9svfL2WrKeuK8W08xeR5lTn8.jpg",
            "/1H2xEZOixs0z0JKwyjANZiKNNVJ.jpg",
            "/gPbM0MK8CP8A174rmUwGsADNYKD.jpg",
            "/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg",
            "/nrtbv6Cew7qC7k9GsYSf5uSmuKh.jpg",
            "/sFC1ElvoKGdHJIWRpNB3xWJ9lJA.jpg",
            "/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg",
            "/fiVW06jE7z9YnO4trhaMEdclSiC.jpg",
            "/vB8o2p4ETnrfiWEgVxHmHWP9yRl.jpg",
            "/ym1dxyOk4jFcSl4Q2zmRrA5BEEN.jpg",
            "/mcz8oi9oCgq1wkA3Wz2kluE94pE.jpg",
            "/d07phJqCx6z5wILDYqkyraorDPi.jpg",
            "/1kdmre0wlUAUk9BvySv4Xoveieg.jpg",
        ][index]
    }
    private func releaseDate(at index: Int) -> String {
        return [
            "2023-08-02",
            "2023-07-19",
            "2023-09-06",
            "2023-06-28",
            "2023-06-14",
            "2023-08-17",
            "2023-07-31",
            "2023-07-03",
            "2023-06-16",
            "2023-06-06",
            "2023-05-31",
            "2023-08-09",
            "2018-09-05",
            "2023-06-13",
            "2023-05-17",
            "2023-08-09",
            "2023-05-18",
            "2023-08-04",
            "2023-07-05",
            "2023-07-28",
        ][index]
    }
    private func title(at index: Int) -> String {
        return [
            "Meg 2: The Trench",
            "Barbie",
            "The Nun II",
            "Indiana Jones and the Dial of Destiny",
            "Elemental",
            "Strays",
            "Teenage Mutant Ninja Turtles: Mutant Mayhem",
            "Sound of Freedom",
            "Adipurush",
            "Transformers: Rise of the Beasts",
            "Spider-Man: Across the Spider-Verse",
            "The Last Voyage of the Demeter",
            "The Nun",
            "The Flash",
            "Fast X",
            "Heart of Stone",
            "The Little Mermaid",
            "Mob Land",
            "Insidious: The Red Door",
            "The Mistress",
        ][index]
    }
    private func video(at index: Int) -> Bool {
        return [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
        ][index]
    }
    private func voteAverage(at index: Int) -> Double {
        return [
            7.0,
            7.3,
            6.9,
            6.7,
            7.8,
            7.4,
            7.3,
            8.0,
            5.0,
            7.5,
            8.4,
            7.3,
            5.9,
            6.9,
            7.3,
            7.0,
            6.6,
            6.0,
            6.9,
            4.9,
        ][index]
    }
    private func voteCount(at index: Int) -> Int {
        return [
            1595,
            4060,
            85,
            1491,
            1838,
            172,
            398,
            437,
            33,
            3115,
            4128,
            515,
            5931,
            2772,
            3617,
            1033,
            1908,
            18,
            1073,
            7,
        ][index]
    }
}

