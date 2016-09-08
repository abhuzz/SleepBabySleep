//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, SegueHandlerType {
    
    private let recordingFileExtension = "caf"
    private let cellIdentifier = "PlaylistCollectionViewCell"
    
    private var backgroundAudioPlayer: BackgroundAudioPlayer?
    private var audioRecorder: AudioRecorder?
    private var recordedSoundFileDirectory: RecordedSoundFileDirectory?
    private var playList: SoundFilePlaylist?
    private var lastSelectedItemIndexPath: NSIndexPath?
    private var lastRecordedFileURL: NSURL?
    
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
        
        recordedSoundFileDirectory = RecordedSoundFileDirectory(pathExtensionForRecordings: recordingFileExtension)
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
    
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        
        backgroundAudioPlayer = TimedBackgroundAudioPlayer(audioPlayer: AVAudioPlayerFacade(), timer: SystemTimer())
        backgroundAudioPlayer!.stateDelegate = self
        backgroundAudioPlayer!.selectedSoundFile = playList!.first()
        backgroundAudioPlayer!.playbackDuration = playbackDurationsBySegementIndex[0]
        
        playlistCollectionView.dataSource = self
        playlistCollectionView.delegate = self
        playlistCollectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        
        initRemoteCommands()
    }
    
    override func viewDidAppear(animated: Bool) {
        updateSoundFileSelectionFromPlaylist()
    }
    
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    @IBAction func actionTappedPrevious(sender: AnyObject) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.previous()
    }
    
    @IBAction func actionTappedNext(sender: AnyObject) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.next()
    }
    
    @IBAction func playbackDurationValueChanged(sender: AnyObject) {
        
        let selectedSegmentIndex = playbackDurationSegements.selectedSegmentIndex
        
        guard let selectedPlaybackDuration = playbackDurationsBySegementIndex[selectedSegmentIndex] else { return }

        backgroundAudioPlayer!.playbackDuration = selectedPlaybackDuration
    }
    
    @IBAction func recordTouchUp(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        guard appDelegate.microphoneAvailable else {
            showAlertDialog("The microphone access for this app is disabled. Please enable it in the settings to record your sounds")
            return
        }
        
        if backgroundAudioPlayer!.playState == .Playing {
            backgroundAudioPlayer!.togglePlayState()
        }
        
        performSegueWithIdentifier(.ShowSegueToRecordView, sender: self)
    }
    
    
    func updateSoundFileSelectionFromPlaylist() {
        
        scrollToCellAndHightlightIt(NSIndexPath(forRow: playList!.index, inSection: 0))
    }
    
    func scrollToCellAndHightlightIt(indexPath: NSIndexPath) {
        
        lastSelectedItemIndexPath = indexPath
        
        playlistCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: true)
        
        updateSelectedCellHighlighting()
    }
    
    func availableSoundFiles() -> [SoundFile] {
        
        var soundFiles = [SoundFile]()
        
        do {
            try soundFiles.appendContentsOf(AssetSoundFilePList().assetSoundFilesInPList())
            try soundFiles.appendContentsOf(RecordedSoundFilesPList().recordedSoundFilesInPList())
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
        
        return soundFiles
    }
    
    func reload() {
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
        
        playlistCollectionView.reloadData()
        
        backgroundAudioPlayer?.selectedSoundFile = playList?.first()
        playlistCollectionView.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Bottom)
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playList!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! PlaylistCollectionViewCell
        
        cell.soundFile = playList!.byRow(indexPath.item)
        
        let swipeDeleteGesture = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDeleteCell) )
        swipeDeleteGesture.direction = UISwipeGestureRecognizerDirection.Right
        cell.userInteractionEnabled = true
        cell.addGestureRecognizer(swipeDeleteGesture)
        
        return cell
    }
    
    func collectionViewDeleteCell(sender: UISwipeGestureRecognizer) {
        
        let cell = sender.view as! PlaylistCollectionViewCell
        
        guard let soundFile = cell.soundFile else { return }
        guard soundFile.Deletable else { return }
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: "Delete \(soundFile.Name)?", preferredStyle: UIAlertControllerStyle.Alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) in  self.deleteSoundFile(soundFile) } ) )
        dialog.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {(alert: UIAlertAction!) in return } ) )
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    func deleteSoundFile(soundFile: SoundFile) {
        
        do {
            try RecordedSoundFilesPList().deleteRecordedSoundFile(soundFile.Identifier)
            try recordedSoundFileDirectory!.deleteFile(soundFile.URL)
            reload()
        } catch let exception as NSError {
            showAlertDialog(exception.localizedDescription)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.jumptoRow(indexPath.row)
        
        scrollToCellAndHightlightIt(indexPath)
        
        if backgroundAudioPlayer?.playState == PlayState.Paused {
            backgroundAudioPlayer?.togglePlayState()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        updateParallaxEffect()
        updateSelectedCellHighlighting()
    }
    
    func updateParallaxEffect() {
        
        let bounds = playlistCollectionView!.bounds
        
        playlistCollectionView.visibleCells().forEach { cell in
            (cell as! PlaylistCollectionViewCell).updateParallaxOffset(collectionViewBounds: bounds)
        }
    }
    
    func updateSelectedCellHighlighting() {
        
        playlistCollectionView.visibleCells().forEach { cell in
            (cell as! PlaylistCollectionViewCell).notSelected()
        }
        
        guard let indexPath = lastSelectedItemIndexPath else { return }
        
        guard let selectedCell = playlistCollectionView.cellForItemAtIndexPath(indexPath) as? PlaylistCollectionViewCell else { return }
        
        selectedCell.currentlySelected()
    }
}

extension ViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(playState: PlayState) {
        
        switch playState {
            
        case .Playing:
            updateTrackInfoInRemoteCommandCenter()
            buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)
            updateSoundFileSelectionFromPlaylist()
            
        case .Paused:
            buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
        }
    }
}

extension ViewController: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: "Insert name", preferredStyle: UIAlertControllerStyle.Alert)
   
        dialog.addTextFieldWithConfigurationHandler(addTextField)
        dialog.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        dialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nameEntered))
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    func nameEntered(alert: UIAlertAction!){
        
        guard let recordingURL = lastRecordedFileURL else { return }
        
        do {
            try RecordedSoundFilesPList().saveRecordedSoundFileToPlist(NSUUID(), name: soundFileName.text!, URL: recordingURL)
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
        
        reload()
    }
    
    func addTextField(textField: UITextField!){
        textField.placeholder = "Definition"
        self.soundFileName = textField
    }
}

extension ViewController { // MPRemoteCommands

    func initRemoteCommands() {
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(ViewController.PlayPauseCommand))
        
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(ViewController.PlayPauseCommand))
        
        commandCenter.nextTrackCommand.enabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(ViewController.nextTrackCommand))
        
        commandCenter.previousTrackCommand.enabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(ViewController.previousTrackCommand))
     
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    func updateTrackInfoInRemoteCommandCenter() {
        
        var albumArtWorkImage = UIImage()
        
        if backgroundAudioPlayer!.selectedSoundFile?.Image != nil {
            albumArtWorkImage = backgroundAudioPlayer!.selectedSoundFile!.Image
        }
        
        let nowPlayingCenter = MPNowPlayingInfoCenter.defaultCenter()
        
        nowPlayingCenter.nowPlayingInfo =
            [MPMediaItemPropertyTitle: backgroundAudioPlayer!.selectedSoundFile!.Name,
             MPMediaItemPropertyAlbumTitle: "Baby sleep",
             MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: albumArtWorkImage),
             MPMediaItemPropertyAlbumTrackCount: NSNumber(int: Int32(playList!.count)),
             MPMediaItemPropertyAlbumTrackNumber: NSNumber(int: Int32(playList!.number)),
             MPMediaItemPropertyPlaybackDuration: NSNumber(float: Float(backgroundAudioPlayer!.playbackDuration!.totalSeconds()))]
        
    }
    
    func PlayPauseCommand() {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    func nextTrackCommand() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.next()
    }
    
    func previousTrackCommand() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.previous()
    }
}


