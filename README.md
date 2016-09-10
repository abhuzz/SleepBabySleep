# SleepBabySleep
iOS & Swift side/learning project
Playous sounds for a given duration until the baby sleeps. Can also record own sounds for repeated playback.

**ToDo**
- [X] Recording dialog
	- [X] Open dialog and add recording button with the same behaviour than currently in the main view. Push and hold to record. 
	- [X] Record into temporary file 
	- [X] Add navigationController (hidden in the main view) 
	- [X] Delete temporary recording when user hits back 
	- [X] When user selects add, move file to the documents directory and store the assignment with the name in the plist file. 
	- [X] Show recording duration 
	- [X] Change recording button while it is recording 
	- [X] Add preview, to listen to the recorded audio before user hits add 
- [ ] Change AVAudioSession for recording
	- [X] AVAudioSessionCategoryPlayback 
	 -[X] AVAudioSessionCategoryPlayAndRecord 
	- [ ] Options: ?AllowBluetooth, MixInWithOthers - https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionBasics/AudioSessionBasics.html
- [ ] Handle AVAudioInterruptions while recording
- [ ] Delete: RecordedSoundFileDirectory? 
- [ ] Selected tracks by previous & next controls when not playing 
- [ ] Delete Recording swipe animation 
- [ ] iPhone plus / iPad UiCollectionView Problem 
- [ ] Store recordings in iCloud Account 
