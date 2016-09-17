//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController, SegueHandlerType {
    
    fileprivate let cellIdentifier = "PlaylistCollectionViewCell"
    
    fileprivate var backgroundAudioPlayer: BackgroundAudioPlayer?
    fileprivate var playList: SoundFilePlaylist?
    fileprivate var lastSelectedItemIndexPath: IndexPath?
    
    private var playbackDurationsBySegementIndex : [Int : PlaybackDuration] =
        [0 : PlaybackDurationMinutes(durationInMinutes: 5),
         1 : PlaybackDurationMinutes(durationInMinutes: 15),
         2 : PlaybackDurationMinutes(durationInMinutes: 30),
         3 : PlaybackDurationMinutes(durationInMinutes: 60),
         4 : PlaybackDurationMinutes(durationInMinutes: 90),
         5 : PlaybackDurationMinutes(durationInMinutes: 120),
         6 : PlaybackDurationInifinite()]
    
    enum SegueIdentifier: String {
        case ShowSegueToRecordView
    }
    
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    @IBOutlet weak var playbackDurationSegements: UISegmentedControl!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
    
        backgroundAudioPlayer =
            TimedBackgroundAudioPlayer(audioSession: AVAudioSessionFacade(), audioPlayer: AVAudioPlayerFacade(), timer: SystemTimer())
        backgroundAudioPlayer!.stateDelegate = self
        backgroundAudioPlayer!.selectedSoundFile = playList!.first()
        backgroundAudioPlayer!.playbackDuration = playbackDurationsBySegementIndex[0]
        
        playlistCollectionView.dataSource = self
        playlistCollectionView.delegate = self
        playlistCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        initRemoteCommands()
    }
    
    override func viewDidAppear(_ animated: Bool) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewControllerRecording = segue.destination as? RecordingViewController {
            viewControllerRecording.recordingDelegate = self
        }
    }
    
    @IBAction func actionTappedPlayPause(_ sender: AnyObject) {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    @IBAction func actionTappedPrevious(_ sender: AnyObject) {
        
        previousTrackInPlaylist()
    }
    
    @IBAction func actionTappedNext(_ sender: AnyObject) {
        
        nextTrackInPlaylist()
    }
    
    @IBAction func playbackDurationValueChanged(_ sender: AnyObject) {
        
        let selectedSegmentIndex = playbackDurationSegements.selectedSegmentIndex
        
        guard let selectedPlaybackDuration = playbackDurationsBySegementIndex[selectedSegmentIndex] else { return }

        backgroundAudioPlayer!.playbackDuration = selectedPlaybackDuration
    }
    
    @IBAction func recordTouchUp(_ sender: AnyObject) {
        
        if backgroundAudioPlayer!.playState == .playing {
            backgroundAudioPlayer!.togglePlayState()
        }
        
        performSegueWithIdentifier(.ShowSegueToRecordView, sender: self)
    }
    
    func nextTrackInPlaylist() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.next()
        updateSoundFileSelectionFromPlaylist()
    }
    
    func previousTrackInPlaylist() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.previous()
        updateSoundFileSelectionFromPlaylist()
    }
    
    func updateSoundFileSelectionFromPlaylist() {
        
        scrollToCellAndHightlightIt(IndexPath(row: playList!.index, section: 0))
    }
    
    func scrollToCellAndHightlightIt(_ indexPath: IndexPath) {
        
        lastSelectedItemIndexPath = indexPath
        
        playlistCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
        updateSelectedCellHighlighting()
    }
    
    func availableSoundFiles() -> [SoundFile] {
        
        var soundFiles = [SoundFile]()
        
        do {
            try soundFiles.append(contentsOf: AssetSoundFilePList().assetSoundFilesInPList())
            try soundFiles.append(contentsOf: RecordedSoundFilesPList().recordedSoundFilesInPList())
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
        
        return soundFiles
    }
    
    func reload() {
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
        
        playlistCollectionView.reloadData()
        
        backgroundAudioPlayer?.selectedSoundFile = playList?.first()
    }
}

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlaylistCollectionViewCell
        
        cell.soundFile = playList!.byRow((indexPath as NSIndexPath).item)
        
        let swipeDeleteGesture = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDeleteCell) )
        swipeDeleteGesture.direction = UISwipeGestureRecognizerDirection.right
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(swipeDeleteGesture)
        
        return cell
    }
    
    func collectionViewDeleteCell(_ sender: UISwipeGestureRecognizer) {
        
        guard let cell = sender.view as? PlaylistCollectionViewCell else { return }
        guard let soundFile = cell.soundFile else { return }
        guard soundFile.Deletable else { return }
        
        cell.swipeRight(animateInView: self.view)
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: "Delete \(soundFile.Name)?", preferredStyle: UIAlertControllerStyle.alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
            
            cell.disappear(animateInView: self.view, animationCompleted: { self.deleteSoundFile(soundFile) })
        } ) )
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            (alert: UIAlertAction!) in
            
            cell.undoSwipe(animateInView: self.view)
            
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        } ) )
        
        present(dialog, animated: true, completion: nil)
    }
    
    func deleteSoundFile(_ soundFile: SoundFile) {
        
        do {
            try RecordedSoundFilesPList().deleteRecordedSoundFile(soundFile.Identifier)
            try FileManager.default.removeItem(at: soundFile.URL as URL)
            reload()
        } catch let exception as NSError {
            showAlertDialog(exception.localizedDescription)
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.jumptoRow((indexPath as NSIndexPath).row)
        
        scrollToCellAndHightlightIt(indexPath)
        
        if backgroundAudioPlayer?.playState == PlayState.paused {
            backgroundAudioPlayer?.togglePlayState()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateParallaxEffect()
    }
    
    func updateParallaxEffect() {
        
        let bounds = playlistCollectionView!.bounds
        
        playlistCollectionView.visibleCells.forEach { cell in
            (cell as! PlaylistCollectionViewCell).updateParallaxOffset(collectionViewBounds: bounds)
        }
    }
    
    func updateSelectedCellHighlighting() {
        
        playlistCollectionView.visibleCells.forEach { cell in
            (cell as! PlaylistCollectionViewCell).notSelected(view: self.view)
        }
        
        guard let indexPath = lastSelectedItemIndexPath else { return }
        
        guard let selectedCell = playlistCollectionView.cellForItem(at: indexPath) as? PlaylistCollectionViewCell else { return }
        
        selectedCell.currentlySelected(view: self.view)
    }
}

extension MainViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(_ playState: PlayState) {
        
        switch playState {
            
        case .playing:
            updateTrackInfoInRemoteCommandCenter()
            buttonPlayPause.setImage(UIImage(named: "Stop"), for: UIControlState())
            updateSoundFileSelectionFromPlaylist()
            
        case .paused:
            buttonPlayPause.setImage(UIImage(named: "Play"), for: UIControlState())
        }
    }
}

extension MainViewController: RecordingDelegate {
    
    func recordingAdded(uuid: UUID) {
        reload()
        
        selectPlaylistItemWithUUID(uuid: uuid)
    }
    
    func selectPlaylistItemWithUUID(uuid: UUID) {
        
        guard let newItemIndex = playList?.indexForUuid(uuid: uuid) else { return }
        
        playList?.jumptoRow(newItemIndex)
        
        scrollToCellAndHightlightIt(IndexPath(row: newItemIndex, section: 0))
    }
}

extension MainViewController { // MPRemoteCommands

    func initRemoteCommands() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MainViewController.PlayPauseCommand))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(MainViewController.PlayPauseCommand))
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(MainViewController.nextTrackCommand))
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(MainViewController.previousTrackCommand))
     
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func updateTrackInfoInRemoteCommandCenter() {
        
        var albumArtWorkImage = UIImage()
        
        if backgroundAudioPlayer!.selectedSoundFile?.Image != nil {
            albumArtWorkImage = backgroundAudioPlayer!.selectedSoundFile!.Image
        }
        
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        
        nowPlayingCenter.nowPlayingInfo =
            [MPMediaItemPropertyTitle: backgroundAudioPlayer!.selectedSoundFile!.Name,
             MPMediaItemPropertyAlbumTitle: "Baby sleep",
             MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: albumArtWorkImage),
             MPMediaItemPropertyAlbumTrackCount: NSNumber(value: Int32(playList!.count) as Int32),
             MPMediaItemPropertyAlbumTrackNumber: NSNumber(value: Int32(playList!.number) as Int32),
             MPMediaItemPropertyPlaybackDuration: NSNumber(value: Float(backgroundAudioPlayer!.playbackDuration!.totalSeconds()) as Float)]
        
    }
    
    func PlayPauseCommand() {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    func nextTrackCommand() {
        
        nextTrackInPlaylist()
    }
    
    func previousTrackCommand() {
        
        previousTrackInPlaylist()
    }
}


