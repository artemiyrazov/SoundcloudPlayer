//
//    TracksPresenter.swift
//     SoundCloudPlayer
//

import UIKit

class TrackListPresenter {
    
    let coreDataService = CoreDataService.shared
    weak var view: TrackListViewProtocol?
    weak var tabBarDelegate: PlayerViewAppearanceDelegate?
    var token: String
    var networkService: TrackListNetworkServiceProtocol?
    var currentTrackList: [Track]?
    
    init(token: String) {
        self.token = token
    }
    
    private func convertTrackListForView(_ trackList: [Track]) -> [TrackViewData] {
        let tracksForView = trackList.map({ track -> TrackViewData in
            let isCached = coreDataService.isTrackCached(with: track.id)
            let cachedStatus: TrackCacheStatus = isCached ? .cached : .notCached
            return TrackViewData(title: track.title,
                                 genre: track.genre,
                                 duration: track.duration.convertMillisecondsDurationToString(),
                                 artworkUrl: track.artworkUrl,
                                 cacheStatus: cachedStatus)
        })
        return tracksForView
    }
}

extension TrackListPresenter: TrackListPresenterProtocol {
    
    func searchTracks(withBody body: String) {
        networkService?.tracksSearchRequest(token: token, searchBody: body, completionHandler: { [weak self] result in
            guard let self = self else { return }
            var tracksForView: [TrackViewData] = []
            switch result {
            case .success(let trackList):
                self.currentTrackList = trackList
                tracksForView = self.convertTrackListForView(trackList)
            case .failure(let error):
                print("Some error with JSON: ", error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.view?.setTrackList(trackList: tracksForView)
            }
        })
    }
    
    func showPlayer(from trackIndex: Int) {
        guard let currentTrackList = currentTrackList else { return }
        let tracksQueue: [Track] = Array(currentTrackList[trackIndex ..< currentTrackList.count])
        tabBarDelegate?.presentFullPlayerScreen(tracksQueue: tracksQueue)
    }
    
    func getTrackList() {
        networkService?.getUserTrackList(token: token) { [weak self] result in
            guard let self = self else { return }
            var tracksForView: [TrackViewData] = []
            switch result {
            case .success(let trackList):
                self.currentTrackList = trackList
                tracksForView = self.convertTrackListForView(trackList)
            case .failure(let error):
                print("Some error with JSON: ", error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.view?.setTrackList(trackList: tracksForView)
            }
        }
    }
    
    func cellButtonTapped(at index: Int) {
        guard let track = currentTrackList?[index] else { return }
        if let artworkUrl = track.largeArtworkUrl {
            networkService?.downloadFileToDevice(from: artworkUrl, token: token, completionHandler: { [weak self] artworkPath in
                guard let self = self else { return }
                self.coreDataService.saveTrackToDevice(track, artworkImagePath: artworkPath, audioFilePath: nil)
            })
        } else {
            coreDataService.saveTrackToDevice(track, artworkImagePath: nil, audioFilePath: nil)
        }
    }
}
