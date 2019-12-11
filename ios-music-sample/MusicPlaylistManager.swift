//
//  MusicPlaylistManager.swift
//  ios-music-sample
//
//  Created by owen on 2019/12/11.
//  Copyright © 2019 nekowen. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct MusicItem: Identifiable, Equatable {
    let id: String
    let assetURL: URL?
    let title: String?
    let albumTitle: String?
    let artwork: MPMediaItemArtwork?
}

class MusicPlaylistManager: ObservableObject {
    @Published var songs: [MusicItem] = []
        
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.fetchSongs()
                case .notDetermined:
                    self?.requestAuthorization()
                default:
                    break
                }
            }
        }
    }

    func fetchSongs() {
        let songQuery = MPMediaQuery.songs()
        let icloudItemPredicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
        let protectedAssetPredicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyHasProtectedAsset)

        songQuery.addFilterPredicate(icloudItemPredicate)
        songQuery.addFilterPredicate(protectedAssetPredicate)

        guard let songItems = songQuery.items else {
            return
        }
        
        self.songs = songItems.map { music in
            return MusicItem(
                id: String(music.persistentID),
                assetURL: music.assetURL,
                title: music.title,
                albumTitle: music.albumTitle,
                artwork: music.artwork
            )
        }
    }
}
