//
//  MusicPlaylistView.swift
//  ios-music-sample
//
//  Created by owen on 2019/12/11.
//  Copyright © 2019 nekowen. All rights reserved.
//

import SwiftUI

struct MusicPlaylistView: View {
    @EnvironmentObject var playManager: MusicPlayManager
    @EnvironmentObject var playlistManager: MusicPlaylistManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var playingItem: MusicItem?
    
    var body: some View {
        NavigationView {
            List(self.playlistManager.songs) { music in
                Button(action: {
                    try? self.playManager.prepare(music)
                    try? self.playManager.play()
                    self.playingItem = music
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(music.title ?? "")
                            .font(Font.system(size: 18).bold())
                        Text(music.albumTitle ?? "")
                            .font(Font.system(size: 14))
                    }
                }
            }
            .navigationBarTitle("曲リスト")
            .onAppear {
                self.playlistManager.requestAuthorization()
            }
        }
    }
}

struct MusicPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        let manager: MusicPlaylistManager = {
            let m = MusicPlaylistManager()
            m.songs = [
                MusicItem(id: "hoge", assetURL: nil, title: "hoge", albumTitle: "hoge", artwork: nil),
                MusicItem(id: "fuga", assetURL: nil, title: "fuga", albumTitle: "hoge", artwork: nil),
                MusicItem(id: "moge", assetURL: nil, title: "moge", albumTitle: "hoge", artwork: nil)
            ]
            return m
        }()
        return MusicPlaylistView(playingItem: .constant(nil)).environmentObject(manager)
    }
}
