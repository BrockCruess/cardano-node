#!/bin/bash
#################################################################################
# Update with the location from which your cardano-node and cardano-cli are run:
NODE_LOCATION="$HOME/.local/bin/"
#################################################################################
# Leave the rest of this:
LATEST=$(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | grep -o -P '"tag_name": "\K[^"]+') && \
CURRENT=$($NODE_LOCATION/cardano-node --version | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" && \
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'
if test "$CURRENT" = "$LATEST"; then
    echo "" && \
    echo -e "${GREEN}***********************${NC}" && \
    echo -e "${GREEN}No new update available${NC}" && \
    echo -e "${GREEN}***********************${NC}" && \
    echo ""
else
    mkdir "$SCRIPTPATH/$LATEST" && \
    cd "$SCRIPTPATH/$LATEST" && \
    echo "" && \
    echo -e "${YELLOW}Downloading latest release of cardano-node and cardano-cli pre-compiled binaries from IntersectMBO's cardano-node repo:${NC}" && \
    echo "https://github.com/IntersectMBO/cardano-node/releases/tag/$LATEST" && \
    wget -q "https://github.com/IntersectMBO/cardano-node/releases/download/$LATEST/cardano-node-$LATEST-linux.tar.gz" && \
    echo -e "${GREEN}Done!${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Extracting files...${NC}" && \
    tar -xf "cardano-node-$LATEST-linux.tar.gz" && \
    echo -e "${GREEN}Done!${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Creating symlink as 'latest'...${NC}" && \
    ln -sf $SCRIPTPATH/$LATEST $SCRIPTPATH/latest && \
    echo -e "${GREEN}Done!${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Stopping cardano-node...${NC}" && \
    sudo systemctl stop cardano-node &>/dev/null && \
    echo -e "${GREEN}Done!${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Moving cardano-node and cardano-cli to $NODE_LOCATION...${NC}" && \
    cp bin/cardano-node "$NODE_LOCATION" && \
    cp bin/cardano-cli "$NODE_LOCATION" && \
    echo -e "${GREEN}Done!${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Restarting cardano-node...${NC}" && \
    sudo systemctl start cardano-node &>/dev/null && \
    echo "Done!" && \
    echo "" && \
    NEW=$($NODE_LOCATION/cardano-node --version | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
    TIME=$(date) && \
    cd "$SCRIPTPATH" && \
    echo "" >> cardano-updates.log && \
    echo "$TIME: Updated from $CURRENT --> $NEW" >> cardano-updates.log && \
    echo "" && \
    echo -e "${GREEN}*********************${NC}" && \
    echo -e "${GREEN}Cardano Node Updated!${NC}" && \
    echo -e "${GREEN}*********************${NC}" && \
    echo "" && \
    echo -e "${YELLOW}Old version:${NC}" && \
    echo -e "${YELLOW}$CURRENT${NC}" && \
    echo "" && \
    echo -e "${GREEN}New version:${NC}" && \
    echo -e "${GREEN}$NEW${NC}" && \
    echo "" && \
    echo "Would you like to delete the unneeded downloaded files? The new Node & CLI binaries will remain where they should be." && \
    echo "Please input 1 for Yes or 2 for No:" && \
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) rm -rf "$LATEST" && echo "" && echo -e "${GREEN}Downloaded files deleted.${NC}" && echo -e "${PURPLE}See you next time!${NC}" && echo ""; break;;
            No ) echo "" && echo -e "${GREEN}Downloaded files remain in $SCRIPTPATH/$LATEST/${NC}" && echo -e "${PURPLE}See you next time!${NC}" && echo "" && exit;;
        esac
    done
fi
