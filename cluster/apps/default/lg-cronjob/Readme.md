# LG Cronjob

Runs a curl command to keep the developer mode session on my TV enabled.

To obtain the token you need to SSH into the TV.

1. Make sure developer mode is enabled on the TV
2. Run the following command to SSH into the TV and obtain the token:
```bash
ssh prisoner@10.13.100.147 -p 9922 -i ~/.ssh/tv_webos -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa cat /var/luna/preferences/devmode_enabled
```
The password for the key can be found in the file `~/.webos/tv/novacom-devices.json`
