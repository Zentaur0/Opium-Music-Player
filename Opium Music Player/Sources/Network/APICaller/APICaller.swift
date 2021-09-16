//
//  APICaller.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import UIKit

// MARK: - Constants

fileprivate struct Constants {
    static let baseAPIURL = "https://api.spotify.com/v1"
}

// MARK: - API Error enum

enum APIError: Error {
    case failedToGetData
    case wrongProvidedURL
}

// MARK: - HTTP Method enum

fileprivate enum HTTPMethod: String {
    case GET
    case POST
}

// MARK: - APICaller

final class APICaller {
    
    private func getData<T: Decodable>(urlString: String,
                                       completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: Constants.baseAPIURL + urlString) else {
            completion(.failure(APIError.wrongProvidedURL))
            return
        }
        
        createRequest(with: url, type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    AppContainer.showAlert(type: .failure, text: APIError.failedToGetData.localizedDescription)
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    
                    completion(.success(decodedObject))
                } catch {
                    AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthentificationManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            completion(request)
        }
    }
    
}

// MARK: - ApiCallerProtocol

extension APICaller: APICallerProtocol {
    
    func getNewReleases(completion: @escaping (Result<NewReleaseResponse, Error>) -> Void) {
        getData(urlString: "/browse/new-releases", completion: completion)
    }
    
    func getAllCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        getData(urlString: "/browse/categories?offset=0&limit=50&country=RU", completion: completion)
    }
    
    func getPlaylist(id: String, completion: @escaping (Result<PlaylistResponse, Error>) -> Void) {
        getData(urlString: "/browse/categories" + "/\(id)" + "/playlists", completion: completion)
    }
    
}

// MARK: - UserAPICallerProtocol

extension APICaller: UserAPICallerProtocol {
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        getData(urlString: "/me", completion: completion)
    }
    
}

// MARK: - SongListAPICallerProtocol

extension APICaller: SongListAPICallerProtocol {
    
    func getPlaylistDetails(for playlist: Playlist,
                            completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        getData(urlString: "/playlists/" + playlist.id, completion: completion)
    }
    
    func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        getData(urlString: "/albums/" + album.id, completion: completion)
    }
    
}

// MARK: - ArtistApiCallerProtocol

extension APICaller: ArtistApiCallerProtocol {
    
    func getArtist(artist id: String, completion: @escaping (Result<Artist, Error>) -> Void) {
        getData(urlString: "/artists/" + id, completion: completion)
    }
    
    func getArtistAlbums(artist id: String, completion: @escaping (Result<ArtistAlbums, Error>) -> Void) {
        getData(urlString: "/artists/" + id + "/albums", completion: completion)
    }
    
    func getArtistTracks(artist id: String, completion: @escaping (Result<ArtistTracks, Error>) -> Void) {
        getData(urlString:  "/artists/" + id + "/top-tracks?market=RU", completion: completion)
    }
    
}

// MARK: - SearchAPICallerProtocol

extension APICaller: SearchAPICallerProtocol {
    
    func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        guard let url = URL(string: Constants.baseAPIURL + "/search?type=album,artist,playlist,track&" + "q=\(query)") else {
            AppContainer.showAlert(type: .failure, text: APIError.wrongProvidedURL.localizedDescription)
            completion(.failure(APIError.wrongProvidedURL))
            return
        }
        
        createRequest(with: url, type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    AppContainer.showAlert(type: .failure, text: APIError.wrongProvidedURL.localizedDescription)
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap { .track(model: $0) })
                    searchResults.append(contentsOf: result.albums.items.compactMap { .album(model: $0) })
                    searchResults.append(contentsOf: result.playlists.items.compactMap { .playlist(model: $0) })
                    searchResults.append(contentsOf: result.artists.items.compactMap { .artist(model: $0) })
                    
                    completion(.success(searchResults))
                } catch {
                    AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
}
