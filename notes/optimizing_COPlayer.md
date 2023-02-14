# Optimizing ClientObjectPlayer
This is a list of optimizations I plan to implement into [ClientObjectPlayer](https://github.com/UTheDev/softlocked-v2/blob/main/src/client/LevelPlayer/ClientObjectPlayer.lua). Over time, I may add or remove stuff here. I may not actually implement these soon, but for those that want to implement these themselves, please feel free to use this document.

## Caching ClientObject value references
To make it less computationally expensive to start/restart a tower, save references of ClientObject values into an array. This is because a modern-day tower often contains over 4000 instances in the ClientObject folder, and ClientObject values typically only take up roughly 3% to 20% of this large total. While this may not be such an issue for higher-end devices, lower-end devices receive large lag spikes when you iterate over thousands of instances.

As of writing, ClientObjectPlayer only clones instances that have a ClientObject value parented to it. When caching references to ClientObject values, the cloning loop would only have to iterate through significantly less instances if just 10% of the instances in the ClientSidedObjects folder are ClientObject values.
