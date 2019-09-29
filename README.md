# Corroborator-iOS

use Xcode 10.3
iOS 12

Connect an iPhone with iOS version 12+, open the `.xcworkspace`, and hit run.

Pictures are automatically uploaded to IPFS and the Content Identifier (CID - hash of the jpeg) is uploaded to the Ethereum Rinkeby network with accompanying metadata: time, location.

When offline, pictures are placed in a queue and uploaded when the app has internet access. The queue persists after the app is quit. Check the Offline Queue to see files to be synced and notified when they're synced to IPFS. 
