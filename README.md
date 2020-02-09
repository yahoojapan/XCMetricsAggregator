![](./assets/XCMetricsAggregator.png)

## What's this?

XCMetricsAggregator aggregates metrics across all apps from [Xcode Metrics Organizer](https://help.apple.com/xcode/mac/current/#/devb642b28ac) by automating Xcode with AppleScript.

## Setup

1. Install Xcode 11 from App Store

2. Login with your Apple ID on Accounts preferences in Xcode

3. check a privacy setting to use AppleScript


## Getting Started

### Downloading metrics data 
```
bundle exec exe/xcmagg crowl
```

### application lookup in metrics data
```
bundle exec exe/xcmagg apps
```

### available devices for your apps
```
bundle exec exe/xcmagg devices --bundle_ids yourapp1,yourapp2
```

### available percentiles for your apps
```
bundle exec exe/xcmagg percentiles --bundle_ids yourapp1,yourapp2
```

### launch time metrics for an app
```
bundle exec exe/xcmagg metrics --section launchTime --bundle_id yourapp1 
```

### Compare launch times between your apps
```
bundle exec exe/xcmagg latest --section launchTime --device iPhone11,6 --percentile com.apple.dt.metrics.percentile.ninetyFive
```

### Send the metrics to your log server with CSV format
```
bundle exec exe/xcmagg latest --section launchTime --device iPhone11,6 --percentile com.apple.dt.metrics.percentile.ninetyFive --format csv
```

### Show the metrics on your in-house tool with HTML format
```
bundle exec exe/xcmagg latest --section launchTime --device iPhone11,6 --percentile com.apple.dt.metrics.percentile.ninetyFive --format html
```

## Run with Launchd

If you would like to run script periodically, you can use launchd.

Create plist file to `~/Library/LaunchAgents/xcode-metrics.plist`. 

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>xcode-metrics</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>/your/path/xcode-metrics-automation/run.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
      <key>Hour</key>
      <integer>12</integer>
      <key>Minute</key>
      <integer>10</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/xcode-metrics.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/xcode-metrics.err</string>
</dict>
</plist>
```

Run this command in Terminal to enable the setting.

```
launchctl load ~/Library/LaunchAgents/xcode-metrics.plist
```

## License

This software is released under the MIT License, see LICENSE.
