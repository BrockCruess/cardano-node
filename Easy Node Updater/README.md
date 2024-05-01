Are you tired of downloading new pre-compiled binaries, untarring everything then copying `cardano-node` and `cardano-cli` to the right directory every time there's a new update? Wow, that's lazy, but I feel you. Let me help!

This handy little script will download the latest official release of [Cardano Node](https://github.com/IntersectMBO/cardano-node), extract the files, stop your node, copy `cardano-node` and `cardano-cli` to the directory of your preference, then restart your node - all with some nice console printouts for confirmations along the way and a nice cleanup option at the end.

<br>

> [!IMPORTANT]
> This script will only work if you run Cardano Node as a systemd service.
> 
> You will be prompted for your admin password to stop and start the node's service.
>
> Please remember to check the release notes of each update for any changes to configuration or genesis files. This script will only update the binaries, it won't update your configuration or genesis files.


# Setup:

<br>

- In the directory you'd like to run the updater script from and download the update files to (optionally temporary), run this command to download the script itself:
```
curl https://raw.githubusercontent.com/BrockCruess/cardano-node/main/Easy%20Node%20Updater/cardano-node-updater.sh > cardano-node-updater.sh && chmod +x cardano-node-updater.sh
```
<br>

- Edit the script and update the following part at the beginning with the directory of your `cardano-node` and `cardano-cli` binaries:
```
#################################################################################
# Update with the location from which your cardano-node and cardano-cli are run:
NODE_LOCATION="$HOME/.local/bin/"
#################################################################################
```
<br>

- Run the script any time you'd like to update your Cardano Node:
```
./cardano-node-updater.sh
```
