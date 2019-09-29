# Corroborator-iOS

use Xcode 10.3
iOS 12

## Installation
Connect an iPhone with iOS version 12+, open the `.xcworkspace`, and hit run.

## Usage

All pictures are stored in the user's default photo album and can be easily taken off the device. In addition:

While **online**:
Pictures are automatically uploaded to IPFS and the Content Identifier (CID - hash of the jpeg) is uploaded to the Ethereum Rinkeby network with accompanying metadata: time, location.


While **offline**:
When offline, pictures are saved to the application's secure directory and their locations are placed in a queue to be uploaded. Even if the user changes the photo in their default photo album, this doesn't change the image and CID uploaded to IPFS and Ethereum. The offline queue is consumed and the saved images are uploaded as soon as the app has internet access. The offline queue persists after the app is restarted. Tap the "Offline Queue" button to see files to be synced and see notifications when they're synced to IPFS and Ethereum. 

**Auditor image dashboard**: https://pinata.cloud/pinexplorer  
**Ethereum contract address**: 0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885  
**To see transactions sent to the contract**: https://rinkeby.etherscan.io/address/0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885  
