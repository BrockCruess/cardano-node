#!/bin/bash
#################################################################################
# Update with the location from which your cardano-node and cardano-cli are run:
NODE_LOCATION="$HOME/.local/bin/"
#################################################################################
# Leave the rest of this:
LATEST=$(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | grep -o -P '"tag_name": "\K[^"]+') && \
CURRENT=$($NODE_LOCATION/cardano-node --version | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" && \
if test "$CURRENT" = "$LATEST"; then
    echo "" && \
    echo "***********************" && \
    echo "No new update available" && \
    echo "***********************" && \
    echo ""
else
    mkdir "$SCRIPTPATH/$LATEST" && \
    cd "$SCRIPTPATH/$LATEST" && \
    echo "" && \
    echo "Downloading latest release of cardano-node and cardano-cli pre-compiled binaries from IntersectMBO's cardano-node repo:" && \
    echo "https://github.com/IntersectMBO/cardano-node/releases/tag/$LATEST" && \
    wget -q "https://github.com/IntersectMBO/cardano-node/releases/download/$LATEST/cardano-node-$LATEST-linux.tar.gz" && \
    echo "Done!" && \
    echo "" && \
    echo "Extracting files..." && \
    tar -xf "cardano-node-$LATEST-linux.tar.gz" && \
    echo "Done!" && \
    echo "" && \
    echo "Stopping cardano-node..." && \
    sudo systemctl stop cardano-node &>/dev/null && \
    echo "Done!" && \
    echo "" && \
    echo "Moving cardano-node and cardano-cli to $NODE_LOCATION..." && \
    cp bin/cardano-node "$NODE_LOCATION" && \
    cp bin/cardano-cli "$NODE_LOCATION" && \
    echo "Done!" && \
    echo "" && \
    echo "Restarting cardano-node..." && \
    sudo systemctl start cardano-node &>/dev/null && \
    echo "Done!" && \
    echo "" && \
    NEW=$($NODE_LOCATION/cardano-node --version | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
    TIME=$(date) && \
    cd "$SCRIPTPATH" && \
    echo "" >> cardano-updates.log && \
    echo "$TIME: Updated from $CURRENT --> $NEW" >> cardano-updates.log && \
    echo "" && \
    echo "*********************" && \
    echo "Cardano Node Updated!" && \
    echo "*********************" && \
    echo "" && \
    echo "Old version:" && \
    echo "$CURRENT" && \
    echo "" && \
    echo "New version:" && \
    echo "$NEW" && \
    echo "" && \
    echo "Would you like to delete the unneeded downloaded files? The new Node & CLI binaries will remain where they should be." && \
    echo "Please input 1 for Yes or 2 for No:" && \
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) rm -rf "$LATEST" && echo "" && echo "Downloaded files deleted." && echo "See you next time!" && echo ""; break;;
            No ) echo "" && echo "Downloaded files remain in $SCRIPTPATH/$LATEST/" && echo "See you next time!" && echo "" && exit;;
        esac
    done
fi
