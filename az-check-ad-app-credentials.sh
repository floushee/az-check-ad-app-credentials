#!/bin/bash
appIds=($(az ad app list --query [].appId --output tsv))
threshold=$(date -d "+30 days" +%s)
today=$(date +%s)
for appId in "${appIds[@]}"; do
    displayName=$(az ad app show --id $appId --query displayName --output tsv)
    # get expiry dates
    expiryDates=($(az ad app credential list --id $appId --query [].endDate --output tsv))
    for expiryDate in "${expiryDates[@]}"; do
        # parse date
        expiryDate=$(date -d $expiryDate +%s)
        if [ $today -ge $expiryDate ]; then
            echo "Found expired credentials for $displayName ($appId)"
        else
            if [ $threshold -ge $expiryDate ]; then
                echo "Found credentials for $displayName ($appId) that will expire soon"
            fi
        fi
    done
done
