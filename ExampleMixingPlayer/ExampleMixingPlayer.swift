//
//  ExampleMixingPlayer.swift
//  ExampleMixingPlayer
//
//  Created by Arveen kumar on 7/9/20.
//  Copyright © 2020 Feed FM. All rights reserved.
//

import Foundation
import FeedMedia

public class ExampleMixingPlayer : NSObject, MixingAudioPlayer {
    
    
    public override init() {
        
        self.volume = 1
        self.normalizeVolume = false
        self.trimmingEnabled = false
        self.secondsOfCrossfade = 0
        self.crossfadeInEnabled = false
        self.state = FMAudioPlayerPlaybackState.uninitialized
        self.itemQueue = Array()
        self.downloadedQueue = Array()
        eventDelegate = nil
        super.init()
        
    }
    
    private var itemQueue:Array<FMAudioItem>
    private var downloadedQueue:Array<FMAudioItem>
    
    
    
// MARK: MixingAudioPlayer methods
    
    
    // Send out events so
    public var eventDelegate: FMMixingAudioPlayerDelegate?
    
    public var volume: Float {
        
        didSet{
            // Player.setvolume
        }
    }
    // can be safely ignored
    public var normalizeVolume: Bool
    
    // Enables or disables trimming of songs to cut out the beginning or the end parts
    // Can be implemented if desired, FMaudioItem.trimStart  && FMaudioItem.trimEnd should be the begining and cuttof points of each song
    public var trimmingEnabled: Bool
    
    
    // no of seconds to crossfade, should be ignored as it is too complicated to implement in this scope
    public var secondsOfCrossfade: Float
    
    // Enable disable crossfade, again should be ignored as it is too complicated to implement in this scope
    public var crossfadeInEnabled: Bool
    
    // Update the state of the player
    public var state: FMAudioPlayerPlaybackState {
        didSet {
            // Call event delegate to make sure state change is propagated
            // Also make sure state change even if only propaged if state is actually changed
            eventDelegate?.mixingAudioPlayerStateDidChange(state)
        }
    }
    
    // Currently playing item
    public var currentItem: FMAudioItem?
    
    // Current playback time of the item being played
    public var currentTime: CMTime{
         get {
            // replace with actual playback time
            return CMTime(seconds: 30, preferredTimescale: 1000000)
        }
    }
    // Total duration of the current song
    public var currentDuration: CMTime {
        
        get {
            // Return the fduration of Current item if there is one
            return CMTime(seconds: currentItem?.duration ?? 0, preferredTimescale: 1000000)
        }
    }
    
    
    // New file received from feed, download it immidiately
    public func add(_ audioItem: FMAudioItem) {
        
        FileDownloader.loadFileAsync(url: audioItem.contentUrl!) { (path, error) in
            
            audioItem.contentUrl = path
            // Add file to queue
            self.downloadedQueue.append(audioItem)
            // Send event saying it is ready for playback, can be done later when the item is loaded in the player for lag less playback
            self.eventDelegate?.mixingAudioPlayerItemIsReady(forPlayback: audioItem)
            // If we are waiting for item to be ready start playback asap
            if(self.state == FMAudioPlayerPlaybackState.waitingForItem) {
                //Begin play back now
            }
        }
    }
    
    // Play the file using the AVAudioEngine
    public func play() {
        // play the next song
        
        if(downloadedQueue.isEmpty )
        {
            state = FMAudioPlayerPlaybackState.waitingForItem
        }
        else{
            // Get the first song, make it current item
             currentItem = downloadedQueue.removeFirst()
            // Send the event saying we have started playing the song.
            // Important! or we won't get the next song
            eventDelegate?.mixingAudioPlayerItemDidBeginPlayback(currentItem!, waitingTimeForPlayBack: 0, bufferingTimeforItem: 0)
             // Simulate playing a song
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let randomNumber = Int.random(in: 1...50)
                print("Number: \(randomNumber)")

                if randomNumber == 10 {
                    timer.invalidate()
                    // Send evnt that player reached end
                    self.eventDelegate?.mixingAudioPlayerItemDidFinishPlayback(self.currentItem!, dueTo: FMMixingAudioPlayerCompletionReason.reachedEnd, andError: nil)
                }
                
                if randomNumber == 19 {
                    timer.invalidate()
                    // simulate an error in playback
                    self.eventDelegate?.mixingAudioPlayerItemDidFinishPlayback(self.currentItem!, dueTo: FMMixingAudioPlayerCompletionReason.error, andError: nil)
                }
            }
        }
        
    }
    
    // Pause
    public func pause() {
        
    }
    
    public func skip() {
        
        // call Player.skip()
        self.eventDelegate?.mixingAudioPlayerItemDidFinishPlayback(currentItem!, dueTo: FMMixingAudioPlayerCompletionReason.skipped, andError: nil)
        
    }
    // Just skip since no crossfade support
    public func skip(withCrossfade applyCrossfade: Bool) {
        //player.skip
    }
    
    // continue playing current song but clear all pending items
    public func flush() {
        downloadedQueue.removeAll()
    }
    
    // Pause playback and clear items and all downloaded date
    public func flushAndIncludeCurrentItem(_ includeCurrentItem: Bool) {
        
        pause()
        //player.removeCurrentItem
        eventDelegate?.mixingAudioPlayerItemDidFinishPlayback(self.currentItem!, dueTo: FMMixingAudioPlayerCompletionReason.flushed, andError: nil)
        flush()
    }
    
    // Ignore it
    public func seekStation(to setTime: CMTime) {
        
    }
    // Ignore it
    public func maxSeekableLength() -> CMTime {
        return CMTime(seconds: 0, preferredTimescale: 10000)
    }
    
    // Ignore it
    public func cancelSecondaryItem() {
        
    }
    
    
    
    
    
}



