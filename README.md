# 42-Logtime-Checker

## Info
#### Apparently the API only returns the log time with a 2 day delay from the location_stats endpoint, might try a different solution but it works for now

## Important
#### Navigate to your intra profile, top-right corner click on your profile, settings API, create a new app and have the client id and client token ready for the script, since i didn't use a redirect-uri, will do it later



### How to install:
#### Copy the following command and paste it in your terminal, it will clone the repo, install the required libraries and ask for your client id and client secret
```bash
curl -sSL https://github.com/Dwimpy/42-Logtime-Checker/raw/main/install.sh -o install.sh && chmod +x ./install.sh && $(basename $SHELL) ./install.sh 
```

### How to use:
#### The script adds two environment variables that the program uses LOGTIME_CLIENT_ID and LOGTIME_CLIENT_SECRET, if the secret expires you need to refresh it, otherwise type:
```bash
logtime
```
