//
//  ContentView.swift
//  Shared
//
//  Created by Oleksii Huralnyk on 14.10.2021.
//

import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    let categories: [AVAudioSession.Category] = [
        .ambient,
        .multiRoute,
        .playAndRecord,
        .playback,
        .record,
        .soloAmbient
    ]

    let options: [AVAudioSession.CategoryOptions] = [
        .mixWithOthers,
        .duckOthers,
        .interruptSpokenAudioAndMixWithOthers,
        .allowBluetooth,
        .allowBluetoothA2DP,
        .allowAirPlay,
        .defaultToSpeaker
    ]

    @State
    var category: AVAudioSession.Category = .playback

    @State
    var selected: AVAudioSession.CategoryOptions = []

    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Category")
                    .font(.headline)

                ForEach(categories) { category in
                    HStack() {
                        Text(category.debugDescription)
                        Spacer()
                        if self.category == category {
                            Image(systemName: "checkmark")
                        }
                    }.onTapGesture {
                        self.category = category
                    }
                    .padding(4)
                }
            }

            VStack {
                Text("Category options")
                    .font(.headline)

                ForEach(options) { option in
                    HStack() {
                        Text(option.debugDescription)
                        Spacer()
                        if selected.contains(option) {
                            Image(systemName: "checkmark")
                        }
                    }.onTapGesture {
                        if selected.contains(option) {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    }
                    .padding(4)
                }
            }

            HStack {
                AirPlayView()
                    .frame(width: 44, height: 44, alignment: .leading)

                Text(Player.shared.outputs.first ?? "Unknown")
            }
            .padding(.top, 64)

            Spacer()

            Button("Play") {
                Player.shared.play(category: category, options: selected)
            }
        }
        .padding()
    }
}

struct AirPlayView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let routePicker = AVRoutePickerView()
        return routePicker
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

extension AVAudioSession.Category: CustomDebugStringConvertible, Identifiable {

    public var id: String {
        return self.debugDescription
    }

    public var debugDescription: String {
        switch self {
        case .ambient:
            return "ambient"
        case .multiRoute:
            return "multiRoute"
        case .playAndRecord:
            return "playAndRecord"
        case .playback:
            return "playback"
        case .record:
            return "record"
        case .soloAmbient:
            return "soloAmbient"
        default:
            return ""
        }
    }
}

extension AVAudioSession.CategoryOptions: CustomDebugStringConvertible, Identifiable, Hashable {

    public var id: String {
        return self.debugDescription
    }

    public var debugDescription: String {
        switch self {
        case .mixWithOthers:
            return "mixWithOthers"
        case .duckOthers:
            return "duckOthers"
        case .interruptSpokenAudioAndMixWithOthers:
            return "interruptSpokenAudioAndMixWithOthers"
        case .allowBluetooth:
            return "allowBluetooth"
        case .allowBluetoothA2DP:
            return "allowBluetoothA2DP"
        case .allowAirPlay:
            return "allowAirPlay"
        case .defaultToSpeaker:
            return "defaultToSpeaker"
        default:
            return "unknown"
        }
    }

    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

final class Player: NSObject, AVAudioPlayerDelegate {

    static let shared = Player()

    var outputs: [String] {
        session.currentRoute.outputs.map { $0.portName }
    }

    private let session: AVAudioSession = .sharedInstance()

    private lazy var player: AVAudioPlayer? = {
        do {
            let url = Bundle.main.url(forResource: "example", withExtension: "mp3")
            let player = try url.map(AVAudioPlayer.init(contentsOf:))
            player?.delegate = self
            return player
        } catch {
            return nil
        }
    }()

    private override init() {
        super.init()
    }

    func play(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) {
        do {
            try session.setCategory(category, mode: .default, options: options)
            try session.setActive(true)
            player?.play()
        } catch {
            print("Failed to start playing audio", error)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Failed to deactivate audio session", error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
