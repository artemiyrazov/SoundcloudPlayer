//
//	TracksPresenter.swift
// 	SoundCloudPlayer
//

import UIKit

class TrackListPresenter {
    var token: String
    
    init(token: String) {
        self.token = token
    }
    
    weak var view: TrackListViewProtocol?
    var networkService: TrackListNetworkServiceProtocol?
    
}

extension TrackListPresenter: TrackListPresenterProtocol {
    
    func getTrackList() {
        networkService?.getUserTrackList(token: token) { [weak self] result in
            guard let self = self else { return }
            var tracksForView: [TrackViewData] = []
            switch result {
            case .success(let trackList):
                for track in trackList {
                    tracksForView.append(TrackViewData(id: track.id,
                                                       title: track.title,
                                                       genre: track.genre,
                                                       duration: track.duration.convertMillisecondsDurationToString(),
                                                       artworkUrl: track.artworkUrl))
                }
            case .failure(let error):
                print("Some error with JSON: ", error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.view?.setTrackList(trackList: tracksForView)
            }
        }
    }
}

struct TrackViewData {
    let id: Int
    let title: String
    let genre: String?
    let duration: String
    let artworkUrl: String?
}
