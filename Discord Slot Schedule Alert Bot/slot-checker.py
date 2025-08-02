import discord
import asyncio

##########################################################################################
# Update these with your bot token, user ID, stake pool ID and Cardano file paths:
TOKEN = "bot.token_example" # Your Discord bot token
USER_ID = "1234567890" # Your Discord user id (turn on Developer Mode to acquire this)
POOL_ID = "0df0f6e5a3191520aa0a58268c38fe608d1d931766fc006635f3f2b1" # Your pool id hash
CARDANO_CLI = "/path/to/cardano-cli" # Path to your cardano-cli
SOCKET_PATH = "/path/to/node.socket" # Path to your node socket
SHELLEY_GENESIS = "/path/to/shelley-genesis.json" # Path to your Shelley genesis file
VRF_SKEY = "/path/to/pool/vrf.skey" # Path to your vrf.skey file
##########################################################################################

# Leadership schedule query command compiled from above info
COMMAND = (
    f"{CARDANO_CLI} conway query leadership-schedule "
    f"--mainnet --socket-path {SOCKET_PATH} "
    f"--genesis {SHELLEY_GENESIS} "
    f"--stake-pool-id {POOL_ID} "
    f"--vrf-signing-key-file {VRF_SKEY} --current"
)

async def run_command(command):
    try:
        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        if stdout:
            return stdout.decode().strip()
        elif stderr:
            return stderr.decode().strip()
        else:
            return "No output"
    except asyncio.TimeoutError:
        return "Command timed out."
    except Exception as e:
        return f"Error occurred: {e}"
# Reformat the spacing to better suit a Discord message
def format_output(raw_output):
    try:
        schedule = json.loads(raw_output)
        lines = []
        lines.append("SlotNo                  UTC Time")
        lines.append("-----------------------------------------")
        for item in schedule:
            slot = str(item['slotNumber'])
            time = item['slotTime'].replace("T", " ").replace("Z", " UTC")
            lines.append(f"{slot:<23}{time}")
        return lines
    except Exception as e:
        return [f"Error parsing output: {e}"]

async def send_output(lines):
    try:
        user = await bot.fetch_user(USER_ID)
        for line in lines:
            await user.send(line)
            print("Message sent to user:", USER_ID)
    except discord.HTTPException as e:
        print("An error occurred while sending the message:", e)
    except Exception as e:
        print("An unexpected error occurred:", e)

async def main():
    output = await run_command(COMMAND)
    print("Raw command output:", output)
    lines = format_output(output)
    await send_output(lines)

intents = discord.Intents.default()
bot = discord.Client(intents=intents)

@bot.event
async def on_ready():
    print('Logged in as', bot.user)

loop = asyncio.get_event_loop()
try:
    loop.run_until_complete(bot.login(TOKEN))
    loop.run_until_complete(main())
finally:
    loop.run_until_complete(bot.close())
