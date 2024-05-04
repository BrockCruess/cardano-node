<h1 align="center">
Discord Slot Schedule Alerts<br/><br/>
</h1>

This Python script runs at the start of every new epoch and sends you your stake pool's assigned slot schedule via a Discord private message.

<br/>

## Setup Instructions:

### 1. Create a new Discord server:

- The bot has to be in a server with you to be allowed to send you messages. You don't want anyone else being able to interact with the bot though, so a new private server is needed if you don't already have a private server for your own personal bots.

- Click the + at the bottom of the server list.

![image](https://github.com/BrockCruess/Iagon/assets/54557110/38c0d805-6d19-4149-847c-f312dad9b879)

- No template is needed. At the time of writing this the process to make a new server is:
  - Click "Create My Own"
  - Click "For me and my friends"
  - Name the server something like "My Bots"

> [!WARNING]
> Do not invite anyone else to this server. Only invite your own private bots. Anyone in this server can interact with bots in the server, meaning they can send Iagon commands to your node.



<br/>

### 2. Create a Discord Bot Token:

- On the [Discord Developer Portal](https://discord.com/developers/applications), create a New Application:

![image](https://github.com/BrockCruess/Iagon/assets/54557110/d139547e-d7f9-4d3b-859f-f67f901f6c08)

- Name it "Slot Checker" or something similar. This name will be the bot's username and I don't think it can be changed later even if you rename the application later. Check the box and click "Create":

<img width="447" alt="Screenshot 2024-04-29 at 20 38 21" src="https://github.com/BrockCruess/cardano-node/assets/54557110/592d5d75-e98f-43fc-b715-4e3d12f70f3c">

- Upload a profile picture for the bot if you like

- On the Slot Checker application's page, Navigate to "OAuth2":

![image](https://github.com/BrockCruess/Iagon/assets/54557110/8182391c-278b-42be-876a-5fc97c28457c)

- Under "OAuth2 URL Generator" check "bot", then under "BOT PERMISSIONS" check "Administrator".

- Go to the bottom of the page and click "Copy" to copy the bot's invite URL:

![image](https://github.com/BrockCruess/Iagon/assets/54557110/5bb3f5f7-a6e5-464e-ac18-df16d5a99b26)

- Paste the bot's invite URL in a new tab in your web browser and invite the bot **only** to your new bot server.

- Back on the Discord Developer Portal, on the Iagon Bot application's page, go to "Bot":

![image](https://github.com/BrockCruess/Iagon/assets/54557110/9d6b3036-ccdb-4892-92ac-848bfc8b662e)

- Under "TOKEN", click "Reset Token":

![image](https://github.com/BrockCruess/Iagon/assets/54557110/d7ded603-8e13-4b14-a018-912305a493be)

- Click "Yes, do it!":

![image](https://github.com/BrockCruess/Iagon/assets/54557110/9bfa13a9-3946-4333-a4da-0f11b3c9ef95)

- If you have MFA enabled (which you absolutely should), enter your authentication code and click "Submit":

![image](https://github.com/BrockCruess/Iagon/assets/54557110/c7c90788-f96d-4a57-aa39-43d2c822cdde)

> [!IMPORTANT]
> Always use MFA/2FA with your online accounts. It's way too easy to steal your account if you don't use MFA/2FA.

- Now click "Copy" to copy your Bot Token:

![image](https://github.com/BrockCruess/Iagon/assets/54557110/006bf318-0462-4941-95ae-9c051d83b7a4)

> [!WARNING]
> Never share your bot token with anyone!
> 
> The token shown above was temporarily made for the purposes of this tutorial and no longer exists.

- Paste this token in a temporary text file or somewhere accessible for now, we'll need it later.

- While you're on the `Bot` page, disable `PUBLIC BOT`:

![image](https://github.com/BrockCruess/Iagon/assets/54557110/19b84941-f6c5-4a4d-97f6-baa62754a5a5)



<br/>

### 3. Set up the Python script:

- Install Python 3 or newer.

- Run this command to install the required packages for the Python script:
```
pip install discord asyncio
```

- In the following command, update `HOUR=` and `MINUTE=` to your server's local time equivelant of `21:47 UTC` as well as `SCRIPT_PATH=` to the directory where you'd like to store the Python script and run it from (with no slash at the end), then run the whole command to download and schedule the Python script. If your Python location is not `/usr/bin/python3` please also update `PYTHON=` in this command:
```
HOUR=21
MINUTE=47
SCRIPT_PATH=/directory/to/store/script/with/no/shash/at/end
PYTHON=/usr/bin/python3
curl https://raw.githubusercontent.com/BrockCruess/cardano-node/main/Slot%20Leader%20Checker/slot-checker.py > $SCRIPT_PATH/slot-checker.py
crontabentry="$MINUTE $HOUR * * * [ \$(( (\$(date -u +\%s) - \$(date -u -d '2024-04-03 21:47:00' +\%s)) % (86400 * 5) )) -lt 5 ] && $PYTHON $SCRIPT_PATH/slot-checker.py"
(crontab -l ; echo "$crontabentry")| crontab -
cd $SCRIPT_PATH
```

> [!WARNING]
> If your timezone changes (daylight savings for example), please ensure your server's local time changes appropriately, otherwise set `HOUR` to both hours (comma-separated) that could be UTC's 21st hour. For example, EST/EDT would set `HOUR=16,17`

- Update the Python script with your Discord bot token, Stake Pool ID and all required Cardano file paths.
```
nano slot-checker.py
```
Editing only this part:
```
##########################################################################################
# Update these with your bot token, user ID, stake pool ID and Cardano file paths:
TOKEN = "bot.token_example" # Your Discord bot token
USER_ID = "1234567890" # Your Discord user id (turn on Developer Mode to acquire this)
POOL_ID = "0df0f6e5a3191520aa0a58268c38fe608d1d931766fc006635f3f2b1" # Your pool id hash
CARDANO_CLI = "/path/to/cardano-cli" # Path to your cardano-cli
SOCKET_PATH = "/path/to/node.socket"
SHELLEY_GENESIS = "/path/to/shelley-genesis.json" # Path to your Shelley genesis file
VRF_SKEY = "/path/to/pool/vrf.skey" # Path to your vrf.skey file
##########################################################################################
```

- Press `Ctrl + X` to close the file and `Y` to confirm save, and `Enter` to confirm overwrite.

<br/>

### You're done! The script will run at the start of every new epoch and will send you a private message with your slot schedule for the epoch.
