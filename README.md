# Corroborator-iOS

use Xcode 10.3
iOS 12

## Installation
Connect an iPhone with iOS version 12+, open the `.xcworkspace`, and hit run.

## Usage

While online:
Pictures are automatically uploaded to IPFS and the Content Identifier (CID - hash of the jpeg) is uploaded to the Ethereum Rinkeby network with accompanying metadata: time, location.


While offline:
When offline, pictures are placed in a queue and uploaded to IPFS and Ethereum as soon as the app has internet access. The offline queue persists after the app is restarted. Tap the Offline Queue button to see files to be synced and see notifications when they're synced to IPFS. 

Auditor image dashboard: https://pinata.cloud/pinexplorer
Ethereum contract address: 0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885
To see transactions sent to the contract: https://rinkeby.etherscan.io/address/0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885
