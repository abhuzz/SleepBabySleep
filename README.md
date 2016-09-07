# SleepBabySleep
iOS App, plays sounds to help baby's fall asleep

**ToDo**
[ ] Recording dialog
	[ ] Open dialog and add recording button with the same behaviour than currently in the main view. Push and hold to record. 
	[ ] Record into temporary file 
	[ ] Add navigationController (hidden in the main view) 
	[ ] Delete temporary recording when user hits back 
	[ ] When user selects add, move file to the documents directory and store the assignment with the name in the plist file. 
	[ ] Show recording duration 
	[ ] Change recording button while it is recording 
	[ ] After first recording change icon to retry. When recording again delete old file and use a new. 
	[ ] Add preview, to listen to the recorded audio before user hits add 
[ ] Change AVAudioSession for recording
	[ ] AVAudioSessionCategoryPlayback 
	[ ] AVAudioSessionCategoryPlayAndRecord 
	[ ] Options: ?AllowBluetooth, MixInWithOthers - https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionBasics/AudioSessionBasics.html
[ ] Record into temporary file, preview recorded audio - re-record or approve recording 
[ ] Delete: RecordedSoundFileDirectory? 
[ ] Selected tracks by previous & next controls when not playing 
[ ] Delete Recording swipe animation 
[ ] iPhone plus / iPad UiCollectionView Problem 
[ ] Store recordings in iCloud Account 
