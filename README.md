# Corroborator-iOS

**Image recording and fingerprinting app for forensic evidence verification.**  

Images taken on this app are "hashed" to create a Content Identified (CID), or a digital fingerprint of the image and metadata. If a **pixel** is changed in the image, or **any** metadata (location, time, etc.) changed, the CID producted from the edited image will differ from the original. The image is uploaded to the InterPlanetary File Storage (IPFS - a distributed, decentralized storage protocol), and CID published to the Ethereum Rinkeby network, an immutable, decentralized blockchain.

<img src="https://github.com/Corroborator-Net/Corroborator-iOS/blob/master/IMG_0434.png" width="200"> <img src="https://github.com/Corroborator-Net/Corroborator-iOS/blob/master/IMG_0251.png" width="200"> <img src="https://github.com/Corroborator-Net/Corroborator-iOS/blob/master/IMG_0433.png" width="200">


## Installation
Connect an iPhone with iOS version 12+, using Xcode version 10.3 open the `.xcworkspace`, and hit run.

## Usage

All pictures are stored in the user's default photo album for reference. Should a user want access to an image file saved on their device, they should use Itunes file sharing and **not** the photo roll as iOS changes images saved to the photo roll. User's can set the purpose of images, (e.g. "vehicle 1 in traffic incident 56GFH") that applies to photos taken after the purpose is set.

While **online**:  
Pictures are automatically uploaded to IPFS and the Content Identifier (CID - hash of the jpeg) is uploaded to the Ethereum Rinkeby network with accompanying metadata: time, location.


While **offline**:  
Pictures are saved to the application's secure directory and their locations are saved and placed in a queue to be uploaded. Should the user change a photo in their default photo album, this won't change the image and CID uploaded to IPFS and Ethereum. The offline queue is consumed and the saved images are uploaded as soon as the app has internet access. The offline queue persists after the app is restarted. Tap the "Offline Queue" button to see files to be synced and see notifications when they're synced to IPFS and Ethereum. 

**Auditor image dashboard**: https://pinata.cloud/pinexplorer  
**Ethereum contract address**: 0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885  
**To see transactions sent to the contract**: https://rinkeby.etherscan.io/address/0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885  
**To see/download image with CID from above Ethereum contract**: https://gateway.pinata.cloud/ipfs/IMAGE_CID_HERE  

