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
    
    private var initialTrackSelected = false
    
    fileprivate let cellIdentifier = "PlaylistCollectionViewCell"
    fileprivate var backgroundAudioPlayer: BackgroundAudioPlayer?
    fileprivate var playList: SoundFilePlaylist?
    fileprivate var lastSelectedItemIndexPath: IndexPath?
    fileprivate var soundTimer: CFTimeInterval = 0.0
    fileprivate var updateTimer: CADisplayLink?
    
    
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
    @IBOutlet weak var playbackDuration: UILabel!
    @IBOutlet weak var playbackRemaining: UILabel!
    @IBOutlet weak var playbackProgress: UIProgressView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
    
        backgroundAudioPlayer =
            TimedBackgroundAudioPlayer(audioSession: AVAudioSessionFacade(), audioPlayer: AVAudioPlayerFacade(), timer: SystemTimer())
        backgroundAudioPlayer!.stateDelegate = self
        backgroundAudioPlayer!.selectedSoundFile = playList!.first()
        backgroundAudioPlayer!.playbackDuration = playbackDurationsBySegementIndex[1]
        
        playlistCollectionView.dataSource = self
        playlistCollectionView.delegate = self
        playlistCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        initRemoteCommands()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    
        if !initialTrackSelected {
            scrollToCellAndHightlightIt(IndexPath(row: 0, section: 0))
    
            initialTrackSelected = true
        }
        
        updateParallaxEffect()
    }
    
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
    
    fileprivate func nextTrackInPlaylist() {
        
        NSLog("MainViewController.nextTrackInPlaylist()")
        
        DispatchQueue.main.async {
            [unowned self] in
            
            self.backgroundAudioPlayer!.selectedSoundFile = self.playList!.next()
            
            self.updateSoundFileSelection(playListIndex: self.playList!.index)
        }
    }
    
    fileprivate func previousTrackInPlaylist() {
        
        NSLog("MainViewController.previousTrackInPlaylist()")
        
        DispatchQueue.main.async {
            [unowned self] in
            
            self.backgroundAudioPlayer!.selectedSoundFile = self.playList!.previous()
            
            self.updateSoundFileSelection(playListIndex: self.playList!.index)
        }
    }
    
    fileprivate func updateSoundFileSelection(playListIndex: Int) {
        
        NSLog("MainViewController.updateSoundFileSelectionFromPlaylist()")
        
        scrollToCellAndHightlightIt(IndexPath(row: playListIndex, section: 0))
    }
    
    fileprivate func scrollToCellAndHightlightIt(_ indexPath: IndexPath) {
        
        NSLog("MainViewController.scrollToCellAndHightlightIt(\(indexPath))")
        
        lastSelectedItemIndexPath = indexPath
        
        DispatchQueue.main.async{
            self.playlistCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    self.updateSelectedCellHighlighting()
                }
        }
    }
    
    private func availableSoundFiles() -> [SoundFile] {
        
        NSLog("MainViewController.availableSoundFiles()")
        
        var soundFiles = [SoundFile]()
        
        do {
            try soundFiles.append(contentsOf: AssetSoundFilePList().assetSoundFilesInPList())
            try soundFiles.append(contentsOf: RecordedSoundFilesPList().recordedSoundFilesInPList())
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
        
        return soundFiles
    }
    
    fileprivate func reload() {
        
        NSLog("MainViewController.reload()")
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
        
        playlistCollectionView.reloadData()
        
        backgroundAudioPlayer?.selectedSoundFile = playList?.first()
    }
    
    fileprivate func deleteSoundFile(_ soundFile: SoundFile) {
        
        NSLog("MainViewController.deleteSoundFile()")
        
        do {
            if backgroundAudioPlayer?.playState == .playing {
                backgroundAudioPlayer?.togglePlayState()
            }
            try RecordedSoundFilesPList().deleteRecordedSoundFile(soundFile.Identifier)
            try FileManager.default.removeItem(at: soundFile.URL as URL)
            reload()
        } catch let exception as NSError {
            showAlertDialog(exception.localizedDescription)
        }
    }
    
    fileprivate func updateParallaxEffect() {
        
        let bounds = playlistCollectionView!.bounds
        
        playlistCollectionView.visibleCells.forEach { cell in
            (cell as! PlaylistCollectionViewCell).updateParallaxOffset(collectionViewBounds: bounds)
        }
    }
    
    private func updateSelectedCellHighlighting() {
        
        NSLog("MainViewController.upateSelectedCellHighlighting()")
        
        playlistCollectionView.visibleCells.forEach { cell in
            (cell as! PlaylistCollectionViewCell).isSelected = false
        }
        
        guard let indexPath = lastSelectedItemIndexPath else {
            NSLog("lastSelectedItemIndexPath is initial - aborting")
            return
        }
        
        guard let selectedCell = playlistCollectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? PlaylistCollectionViewCell else {
            NSLog("No cell found for indexPath \(indexPath) - aborting")
            return
        }
        
        selectedCell.isSelected = true
    }
}

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playList!.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlaylistCollectionViewCell
        
        cell.soundFile = playList!.byRow((indexPath as NSIndexPath).item)
        
        cell.isUserInteractionEnabled = true
        
        let swipeDeleteGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDeleteCell) )
        swipeDeleteGestureLeft.direction = .left
        cell.addGestureRecognizer(swipeDeleteGestureLeft)
        
        let swipeDeleteGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDeleteCell) )
        swipeDeleteGestureRight.direction = .right
        cell.addGestureRecognizer(swipeDeleteGestureRight)
        
        return cell
    }
    
    @objc func collectionViewDeleteCell(_ sender: UISwipeGestureRecognizer) {
        
        guard let cell = sender.view as? PlaylistCollectionViewCell else { return }
        guard let soundFile = cell.soundFile else { return }
        guard soundFile.Deletable else { return }
        
        if sender.direction == .right {
            cell.swipeRight(animateInView: self.view)
        } else {
            cell.swipeLeft(animateInView: self.view)
        }
        
        let dialog = UIAlertController(
            title: NSLocalizedString("Baby Shhh...", comment: "App name"),
            message: "\(NSLocalizedString("Delete", comment: "Delete")) \(soundFile.Name)?",
            preferredStyle: UIAlertController.Style.alert)
        
        dialog.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK"),
            style: .destructive,
            handler: {
                (alert: UIAlertAction!) in
            
                cell.disappear(animateInView: self.view, animationCompleted: { self.deleteSoundFile(soundFile) })
        } ) )
        
        dialog.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: .cancel,
            handler: {
                (alert: UIAlertAction!) in
            
                cell.undoSwipe(animateInView: self.view)
            
                UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
        } ) )
        
        present(dialog, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        NSLog("MainViewController.collectionView.didSelectItemAt(\(indexPath))")
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.jumptoRow((indexPath as NSIndexPath).row)
        
        scrollToCellAndHightlightIt(indexPath)
        
        if backgroundAudioPlayer?.playState == PlayState.paused {
            backgroundAudioPlayer?.togglePlayState()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateParallaxEffect()
    }
}

extension MainViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(_ playState: PlayState) {
        
        NSLog("MainViewController.playStateChanged(\(playState))")
        
        DispatchQueue.main.async {
            [unowned self] in
            switch playState {
                
            case .playing:
                self.updateTrackInfoInRemoteCommandCenter()
                self.buttonPlayPause.setImage(UIImage(named: "Stop"), for: UIControl.State())
                self.updateSoundFileSelection(playListIndex: self.playList!.index)
                self.startUpdateLoop()
                
            case .paused:
                self.buttonPlayPause.setImage(UIImage(named: "Play"), for: UIControl.State())
                self.stopUpdateLoop()
            }
        }
    }
}

extension MainViewController: RecordingDelegate {
    
    func recordingAdded(uuid: UUID) {
        reload()
        
        selectPlaylistItemWithUUID(uuid: uuid)
    }
    
    func selectPlaylistItemWithUUID(uuid: UUID) {
        
        guard let newItemIndex = playList?.indexForUuid(uuid: uuid) else {
            NSLog("MainViewController.selectPlaylistItemWithUUID(\(uuid)) --> Error, not found!")
            return
        }
        
        guard let newSoundFile = playList?.jumptoRow(newItemIndex) else {
            NSLog("MainViewController.selectPlaylistItemWithUUID(\(uuid)) --> Playlist.jumoToRow(\(newItemIndex)) failed()")
            return
        }
        
        backgroundAudioPlayer?.selectedSoundFile = newSoundFile
        
        scrollToCellAndHightlightIt(IndexPath(row: newItemIndex, section: 0))
        
        NSLog("MainViewController.selectPlaylistItemWithUUID - uuid: \(uuid), index: \(newItemIndex)")
    }
}

extension MainViewController { // TimedUpdateLoop
    
    func startUpdateLoop() {
        
        updateTimer?.invalidate()
        
        updateTimer = CADisplayLink(target: self, selector: #selector(MainViewController.updateLoop))
        updateTimer!.preferredFramesPerSecond = 2
        updateTimer!.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func stopUpdateLoop() {
        
        updateTimer?.invalidate()
        updateTimer = nil
        
        playbackDuration.text = "00:00"
        playbackRemaining.text = "00:00"
        playbackProgress.progress = 0.0
    }
    
    @objc func updateLoop() {
        
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            
            let percentage = Float( backgroundAudioPlayer?.currentPercentagePlayed ?? 0 ) / 100.0
            
            NSLog("MainViewController.updateLoop() - \(percentage) - \(String(describing: backgroundAudioPlayer?.currentTimePlayed)) - \(String(describing: backgroundAudioPlayer?.currentRemainingTime))")
        
            playbackDuration.text = durationToTimeString(backgroundAudioPlayer?.currentTimePlayed  ?? 0)
            playbackRemaining.text = durationToTimeString(backgroundAudioPlayer?.currentRemainingTime ?? 0)
            playbackProgress.progress = percentage
            
            soundTimer = CFAbsoluteTimeGetCurrent()
        }
    }
    
    private func durationToTimeString(_ duration: Int) -> String {
    
        let minutes = ( duration / 60 )
        let seconds = duration % 60

        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
}

extension MainViewController { // MPRemoteCommands

    func initRemoteCommands() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MainViewController.playPauseCommand))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(MainViewController.playPauseCommand))
        
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
             MPMediaItemPropertyAlbumTitle: NSLocalizedString("Baby Shhh...", comment: "App name"),
             MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: albumArtWorkImage),
             MPMediaItemPropertyAlbumTrackCount: NSNumber(value: Int32(playList!.count) as Int32),
             MPMediaItemPropertyAlbumTrackNumber: NSNumber(value: Int32(playList!.number) as Int32),
             MPMediaItemPropertyPlaybackDuration: NSNumber(value: Float(backgroundAudioPlayer!.playbackDuration!.totalSeconds()) as Float)]
        
    }
    
    @objc func playPauseCommand() {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    @objc func nextTrackCommand() {
        
        nextTrackInPlaylist()
    }
    
    @objc func previousTrackCommand() {
        
        previousTrackInPlaylist()
    }
}


