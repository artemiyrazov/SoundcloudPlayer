//
//	TracksProtocols.swift
// 	SoundCloudPlayer
//

import UIKit

protocol TrackListNetworkServiceProtocol: class {
    func getUserTrackList(token: String, complectionHandler: @escaping(Result<[Track], Error>) -> Void)
    func tracksSearchRequest(token: String, searchBody: String, completionHandler: @escaping(Result<[Track], Error>) -> Void)
}

protocol TrackListViewProtocol: class {
    var presenter: TrackListPresenterProtocol? { get set }
    func setTrackList(trackList: [TrackViewData])
}

protocol TrackListPresenterProtocol: class {
    var view: TrackListViewProtocol? { get set }
    var networkService: TrackListNetworkServiceProtocol? { get set }
    var tabBarDelegate: PlayerViewAppearanceDelegate? { get set }
    var token: String { get set }
    func getUserTrackList()
    func searchTracks(withBody body: String)
    func showPlayer(from trackIndex: Int)
}
