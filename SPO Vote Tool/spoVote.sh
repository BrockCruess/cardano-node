#!/bin/bash
######################
#  EDIT THESE PATHS  #
######################
POOL_SKEY="path/to/cold-pool.skey"
POOL_VKEY="path/to/cold-pool.vkey"
PAYMENT_SKEY="path/to/payment.skey"
PAYMENT_ADDR="path/to/payment.addr"
CARDANO_CLI="path/to/cardano-cli"
#################################
#  DO NOT EDIT BELOW THIS LINE  #
#################################
NC='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
# Mode selection
while true; do
    read -p "Input 1 to create a vote transaction, 2 to sign an existing vote transaction, or 3 to submit a signed vote transaction: " input
    if [[ $input == 1 ]]; then
        mode=create
        break
    elif [[ $input == 2 ]]; then
        mode=sign
        break
    elif [[ $input == 3 ]]; then
        mode=submit
        break
    elif [[ -z $input ]]; then
        echo -e "${RED}No input provided.${NC}"
        break
    else
        echo -e "${RED}Error: You must enter either 1, 2, or 3.${NC}"
        echo -e "${YELLOW}Please run the script again to start over.${NC}"
        exit
    fi
done
# Create mode
if [[ $mode == create ]]; then
    while true; do
        read -p "Action Submission Transaction Hash: " actionID
        if [[ $actionID =~ ^[a-zA-Z0-9]+$ ]]; then
            break
        elif [[ -z $actionID ]]; then
            echo -e "${RED}No action transaction hash provided.${NC}"
            break
        else
            echo -e "${RED}Error: You must not include the index (ie. #0).${NC}"
            echo -e "${YELLOW}You will input that in the next step. Please run the script again to start over.${NC}"
            exit
        fi
    done
    while true; do
        read -p "Action Submission Transaction Index (number only): " indexInput
        if [[ $indexInput =~ ^[0-9]+$|^1[0-9]+$|^2[0-9]+$ ]]; then
            actionIndex=$indexInput
            break
        elif [[ -z $indexInput ]]; then
            actionIndex=0
            break
        else
            echo -e "${RED}Error: You must enter a valid number.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done
    while true; do
        echo -e "${YELLOW}Vote Options: Yes, No, Abstain${NC}"
        read -p "Please enter your vote: " voteInput
        if [[ $voteInput =~ ^[yY][eE][sS]$ ]]; then
            vote="yes"
            break
        elif [[ $voteInput =~ ^[nN][oO]$ ]]; then
            vote="no"
            break
        elif [[ $voteInput =~ ^[aA][bB][sS][tT][aA][iI][nN]$ ]]; then
            vote="abstain"
            break
        else
            echo -e "${RED}Error: Vote must be 'yes', 'no', or 'abstain'.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done && \
    mkdir -p tmp && \
    mkdir -p votes && \
    currentDir=$(pwd)
    # Create the vote transaction
    ${CARDANO_CLI} conway governance vote create \
    --$vote \
    --governance-action-tx-id "${actionID}" \
    --governance-action-index "${actionIndex}" \
    --cold-verification-key-file "${POOL_VKEY}" \
    --out-file "votes/${actionID}.vote" && \
    echo -e "Vote file saved as ${currentDir}/votes/${actionID}.vote" && \
    while true; do
        read -p "Would you like to sign the vote transaction locally? (y/n): " voteInput
        if [[ $voteInput =~ ^[yY]$ ]]; then
            break
        elif [[ $voteInput =~ ^[nN]$ ]]; then
            exit
        else
            echo -e "${RED}Error: Vote must be 'yes', 'no', or 'abstain'.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done && \
    # Build and sign the vote transaction
    ${CARDANO_CLI} query utxo \
    --address $(cat "${PAYMENT_ADDR}") \
    --mainnet > tmp/fullUtxo.out && \
    tx_in="$(sed -n 's/^[[:space:]]*\"\([^\"]\{1,\}\)\":.*/\1/p' tmp/fullUtxo.out | head -n 1)" && \
    ${CARDANO_CLI} conway transaction build \
    --tx-in "${tx_in}" \
    --change-address $(cat "${PAYMENT_ADDR}") \
    --vote-file "votes/${actionID}.vote" \
    --witness-override 2 \
    --out-file tmp/vote-tx.raw \
    --mainnet && \
    ${CARDANO_CLI} conway transaction sign \
    --tx-body-file tmp/vote-tx.raw \
    --signing-key-file "${POOL_SKEY}" \
    --signing-key-file "${PAYMENT_SKEY}" \
    --out-file tmp/vote-tx.signed && \
    while true; do
        read -p "Would you like to submit the vote transaction? (y/n): " voteInput
        if [[ $voteInput =~ ^[yY]$ ]]; then
            votePath="tmp/vote-tx.signed"
            break
        elif [[ $voteInput =~ ^[nN]$ ]]; then
            echo -e "Signed vote transaction saved as tmp/vote-tx.signed" && \
            exit
        else
            echo -e "${RED}Error: Vote must be 'yes', 'no', or 'abstain'.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done && \
    # Submit the vote transaction
    ${CARDANO_CLI} conway transaction submit \
    --tx-file "${votePath}" \
    --mainnet && \
    echo && \
    echo && \
        if [[ $vote == "yes" ]]; then
            echo -e "${PURPLE}Successfully voted ${GREEN}${vote}${PURPLE} on action ${PURPLE}${actionID}#${actionIndex}${NC}"
        elif [[ $vote == "no" ]]; then
            echo -e "${PURPLE}Successfully voted ${RED}${vote}${PURPLE} on action ${PURPLE}${actionID}#${actionIndex}${NC}"
        elif [[ $vote == "abstain" ]]; then
            echo -e "${PURPLE}Successfully voted ${YELLOW}${vote}${PURPLE} on action ${PURPLE}${actionID}#${actionIndex}${NC}"
        fi
    echo && \
    rm -rf tmp
# Sign mode
elif [[ $mode == sign ]]; then
    while true; do
        read -p "Input path to vote file to sign: " voteFile
        if [[ -f $voteFile ]]; then
            break
        elif [[ -z $voteFile ]]; then
            echo -e "${RED}Error: You must enter a valid file path.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        else
            echo -e "${RED}Error: You must enter a valid file path.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done
    # Build and sign the vote transaction
    ${CARDANO_CLI} query utxo \
    --address $(cat "${PAYMENT_ADDR}") \
    --mainnet > tmp/fullUtxo.out && \
    tx_in="$(sed -n 's/^[[:space:]]*\"\([^\"]\{1,\}\)\":.*/\1/p' tmp/fullUtxo.out | head -n 1)" && \
    ${CARDANO_CLI} conway transaction build \
    --tx-in "${tx_in}" \
    --change-address $(cat "${PAYMENT_ADDR}") \
    --vote-file "${voteFile}" \
    --witness-override 2 \
    --out-file tmp/vote-tx.raw \
    --mainnet && \
    ${CARDANO_CLI} conway transaction sign \
    --tx-body-file tmp/vote-tx.raw \
    --signing-key-file "${POOL_SKEY}" \
    --signing-key-file "${PAYMENT_SKEY}" \
    --out-file tmp/vote-tx.signed && \
    while true; do
        read -p "Would you like to submit the vote transaction? (y/n): " input
        if [[ $input =~ ^[yY]$ ]]; then
            votePath="tmp/vote-tx.signed"
            break
        elif [[ $input =~ ^[nN]$ ]]; then
            echo -e "Signed vote transaction saved as tmp/vote-tx.signed" && \
            exit
        else
            echo -e "${RED}Error: You must enter 'y' or 'n'.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done && \
    # Submit the vote transaction
    output=$(${CARDANO_CLI} conway transaction submit \
    --tx-file "${votePath}" \
    --mainnet)
    if echo "$output" | grep -q "success"; then
        echo -e "${GREEN}Vote submitted successfully.${NC}"
    else
        echo -e "${RED}Error: Vote submission failed.${NC}"
    fi && \
    echo && \
    rm -rf tmp
# Submit mode
elif [[ $mode == submit ]]; then
    while true; do
        read -p "Input path to signed vote transaction file to submit: " votePath
        if [[ -f $votePath ]]; then
            break
        elif [[ -z $votePath ]]; then
            echo -e "${RED}Error: You must enter a valid file path.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        else
            echo -e "${RED}Error: You must enter a valid file path.${NC}"
            echo -e "${YELLOW}Please run the script again to start over.${NC}"
            exit
        fi
    done
    # Submit the vote transaction
    output=$(${CARDANO_CLI} conway transaction submit \
    --tx-file "${votePath}" \
    --mainnet)
    if echo "$output" | grep -q "success"; then
        echo -e "${GREEN}Vote submitted successfully.${NC}"
    else
        echo -e "${RED}Error: Vote submission failed.${NC}"
    fi && \
    echo && \
    rm -rf tmp
fi
