//
//	CachedLibraryPresenter.swift
// 	SoundCloudPlayer
//

import Foundation

class CachedLibraryPresenter: TrackListPresenterProtocol {
    
    let coreDataService = CoreDataService.shared
    var networkService: TrackListNetworkServiceProtocol?
    weak var view: TrackListViewProtocol?
    weak var tabBarDelegate: PlayerViewAppearanceDelegate?
    var trackList: [CachedTrack] = []
    
    func getTrackList() {
        trackList = coreDataService.fetchTracks()
        let tracksForView = trackList.map { track -> TrackViewData in
            return  TrackViewData(title: track.title ?? "",
                                  genre: track.genre,
                                  duration: Int(track.duration).convertMillisecondsDurationToString(),
                                  artworkUrl: track.artworkImagePath?.absoluteString)
        }
        view?.setTrackList(trackList: tracksForView)
    }
    
    func searchTracks(withBody body: String) {
        print("Search body: \(body)")
    }
    
    func showPlayer(from trackIndex: Int) {
        let tracksQueue = Array(trackList[trackIndex ..< trackList.count]).map { track -> Track in
            return Track(id: Int(track.id),
                         title: track.title ?? "",
                         genre: track.genre,
                         duration: Int(track.duration),
                         artworkUrl: track.artworkImagePath?.absoluteString,
                         streamUrl: track.audioFilePath?.absoluteString)
        }
        tabBarDelegate?.presentFullPlayerScreen(tracksQueue: tracksQueue)
    }
    
    func cellButtonTapped(at index: Int) {}
    
}
