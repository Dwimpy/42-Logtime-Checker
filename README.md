# 42-Logtime-Checker

## Info
#### It returns the correct time now, no more delays

## Important
#### Navigate to your intra profile, top-right corner click on your profile, settings API, create a new app and have the client id and client token ready for the script
#### I didn't use a redirect uri so atm only works by creating an app on your intra profile

### How to install:
#### Copy the following command and paste it in your terminal, it will clone the repo, install the required libraries and ask for your client id and client secret
```bash
curl -sSL https://github.com/Dwimpy/42-Logtime-Checker/raw/main/install.sh -o install.sh && chmod +x ./install.sh && $(basename $SHELL) ./install.sh 
```

### How to use:
#### The script adds two environment variables with the program uses LOGTIME_CLIENT_ID and LOGTIME_CLIENT_SECRET, if the secret expires you need to refresh it, otherwise type:
```bash
logtime
```
