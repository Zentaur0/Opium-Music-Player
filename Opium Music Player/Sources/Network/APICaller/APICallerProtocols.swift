//
//  APICallerProtocols.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 11.09.2021.
//

import Foundation

// MARK: - APICallerProtocols

protocol APICallerProtocol: AnyObject {
    func getAllCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void)
    func getNewReleases(completion: @escaping (Result<NewReleaseResponse, Error>) -> Void)
    func getPlaylist(id: String, completion: @escaping (Result<PlaylistResponse, Error>) -> Void)
}

protocol UserAPICallerProtocol: AnyObject {
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void)
}

protocol SongListAPICallerProtocol: AnyObject {
    func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void)
    func getPlaylistDetails(for playlist: Playlist,
                            completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void)
}

protocol ArtistApiCallerProtocol: AnyObject {
    func getArtistAlbums(artist id: String, completion: @escaping (Result<ArtistAlbums, Error>) -> Void)
    func getArtistTracks(artist id: String, completion: @escaping (Result<ArtistTracks, Error>) -> Void)
    func getArtist(artist id: String, completion: @escaping (Result<Artist, Error>) -> Void)
}

protocol SearchAPICallerProtocol: AnyObject {
    func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void)
}
