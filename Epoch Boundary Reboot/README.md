<h1 align="center">
Epoch Boundary Reboot<br/><br/>
</h1>

Regular server reboots are a healthy way to prevent memory leaks and reclaim resources from tasks that have been running for a long time.

In the case of Cardano nodes, I like to recommend a reboot at the start of every epoch. Because Cardano epochs are every 5 days, but not every 5 calendar days, it can be a little tricky to schedule reboots accordingly.

Below is an easy-to-configure command that will create a crontab entry that will run once per day at 21:55 UTC (10 minutes after epoch boundary time) and use math to calculate if it's an epoch boundary day. If it is an epoch boundary day it will reboot the server.

<br>

In the following command, update `HOUR=` and `MINUTE=` to your server's local time equivelant of `21:55 UTC`. If your timezone changes (daylight savings for example), please ensure your server's local time changes appropriately, otherwise set `HOUR` to both hours (comma-separated) that could be UTC's 21st hour. For example, EST/EDT would set `HOUR=16,17`

```
HOUR=21
MINUTE=55
crontabentry="$MINUTE $HOUR * * * bash -c '(( ( \$(date -u +\%s) - \$(date -u +\%s -d \"2023-03-21 21:50:00\") ) / 86400 \% 5 == 0 )) && /usr/sbin/shutdown -r now'"
(crontab -l ; echo "$crontabentry")| crontab -
```
