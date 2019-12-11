//
//  MusicPlayerView.swift
//  ios-music-sample
//
//  Created by owen on 2019/12/11.
//  Copyright © 2019 nekowen. All rights reserved.
//

import SwiftUI

struct MusicPlayerView: View {
    @EnvironmentObject var playManager: MusicPlayManager
    @EnvironmentObject var playlistManager: MusicPlaylistManager
    @State private var playingMusic: MusicItem?
    @State private var isPresentedPlaylist: Bool = true
    
    var artworkImage: UIImage {
        let artworkSize = CGSize(width: 350, height: 350)
        return self.playingMusic?.artwork?.image(at: artworkSize) ?? UIImage(named: "defaultArtwork")!
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Image(uiImage: self.artworkImage)
                        .resizable()
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    Text(self.playingMusic?.title ?? "-")
                        .font(Font.system(size: 24).bold())
                    Text(self.playingMusic?.albumTitle ?? "-")
                        .font(Font.system(size: 18).bold())
                    HStack {
                        Button(action: {
                            guard let playingMusic = self.playingMusic,
                                let prevItem = self.playlistManager.songs.prevItem(playingMusic) else {
                                self.isPresentedPlaylist = true
                                return
                            }
                            try? self.playManager.prepare(prevItem)
                            try? self.playManager.play()
                            self.playingMusic = prevItem
                        }) {
                            Image("ic_player_prev")
                                .resizable()
                                .foregroundColor(Color("primaryColor"))
                                .frame(width: 64, height: 64)
                        }
                        Button(action: {
                            guard let _ = self.playingMusic else {
                                self.isPresentedPlaylist = true
                                return
                            }
                            try? self.playManager.play()
                        }) {
                            Image("ic_player_play")
                                .resizable()
                                .foregroundColor(Color("primaryColor"))
                                .frame(width: 96, height: 96)
                        }
                        Button(action: {
                            guard let playingMusic = self.playingMusic,
                                let nextItem = self.playlistManager.songs.nextItem(playingMusic) else {
                                self.isPresentedPlaylist = true
                                return
                            }
                            try? self.playManager.prepare(nextItem)
                            try? self.playManager.play()
                            self.playingMusic = nextItem
                        }) {
                            Image("ic_player_next")
                                .resizable()
                                .foregroundColor(Color("primaryColor"))
                                .frame(width: 64, height: 64)
                        }
                    }
                }
                .sheet(isPresented: self.$isPresentedPlaylist) {
                    MusicPlaylistView(playingItem: self.$playingMusic)
                        .environmentObject(self.playManager)
                        .environmentObject(self.playlistManager)
                }
                .navigationBarItems(leading:
                    Button(action: {
                        self.isPresentedPlaylist = true
                    }) {
                        Image("ic_menu")
                            .resizable()
                            .foregroundColor(Color("primaryColor"))
                            .frame(width: 32, height: 32)
                    }
                )
            }
        }
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
            .environmentObject(MusicPlayManager())
            .environmentObject(MusicPlaylistManager())
    }
}
