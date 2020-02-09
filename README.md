![](./assets/XCMetricsAggregator.png)

## What's this?

XCMetricsAggregator aggregates metrics across all apps from [Xcode Metrics Organizer](https://help.apple.com/xcode/mac/current/#/devb642b28ac) by automating Xcode with AppleScript.

## Setup

1. Install Xcode 11.x from App Store or the following link

https://developer.apple.com/download/more/

2. Login with your Apple ID on Accounts preferences in Xcode

<img width="400" alt="スクリーンショット 0002-02-09 18 32 32" src="https://user-images.githubusercontent.com/18320004/74100072-1b04b300-4b6e-11ea-97e0-32239898846d.png">

3. check Accessibility setting in Security & Privacy. Script Editor, System Events and Terminal needs to be checked.

<img width="400" alt="Screen Shot 0002-02-09 at 19 28 25" src="https://user-images.githubusercontent.com/18320004/74100455-789afe80-4b72-11ea-9cef-4ea1704edeac.png">


## Getting Started
There are 2 kinds of command.

- manupulating Xcode automatically
- processing raw json files for metrics data

"crowl" command download the json files with Xcode, and the others process them.

### Downloading metrics data 
```
bundle exec exe/xcmagg crowl
```

This command launches Xcode automatically, and operate your mouse. If you interupt the crowling, input Ctrl + C on the terminal.


### application lookup in metrics data
```
bundle exec exe/xcmagg apps
```

```
+--------------------------------------------+---------------------+
|                        available app list                        |
+--------------------------------------------+---------------------+
| bundle id                                  | status              |
+--------------------------------------------+---------------------+
| yourapp1                                   | has metrics         |
| yourapp2                                   | has metrics         |
+--------------------------------------------+---------------------+
```

### available devices for your apps
```
bundle exec exe/xcmagg devices --b yourapp1,yourapp2
```

```
+--------------+---------------------------------------+------------+
|                           yourapp1                                |
+--------------+---------------------------------------+------------+
| kind         | device                                | id         |
+--------------+---------------------------------------+------------+
| iPhone (All) | iPhone 8                              | iPhone10,1 |
|              | iPhone X                              | iPhone10,3 |
|              | iPhone Xs                             | iPhone11,2 |
|              | iPhone Xs Max                         | iPhone11,6 |
|              | iPhone Xʀ                             | iPhone11,8 |
|              | iPhone 11                             | iPhone12,1 |
+--------------+---------------------------------------+------------+
| iPad (All)   | iPad (6th Generation)                 | iPad7,5    |
|              | iPad (7th generation)                 | iPad7,11   |
|              | iPad Pro (11-inch)                    | iPad8,1    |
|              | iPad Pro (12.9-inch) (3rd Generation) | iPad8,5    |
|              | iPad mini (5th generation)            | iPad11,1   |
|              | iPad Air (3rd generation)             | iPad11,3   |
+--------------+---------------------------------------+------------+

+--------------+---------------------------------------+------------+
|                           yourapp2                                |
+--------------+---------------------------------------+------------+
| kind         | device                                | id         |
+--------------+---------------------------------------+------------+
| iPhone (All) | iPhone 8                              | iPhone10,1 |
|              | iPhone X                              | iPhone10,3 |
|              | iPhone Xs                             | iPhone11,2 |
|              | iPhone Xs Max                         | iPhone11,6 |
|              | iPhone Xʀ                             | iPhone11,8 |
|              | iPhone 11                             | iPhone12,1 |
+--------------+---------------------------------------+------------+
| iPad (All)   | iPad (6th Generation)                 | iPad7,5    |
|              | iPad (7th generation)                 | iPad7,11   |
|              | iPad Pro (11-inch)                    | iPad8,1    |
|              | iPad Pro (12.9-inch) (3rd Generation) | iPad8,5    |
|              | iPad mini (5th generation)            | iPad11,1   |
|              | iPad Air (3rd generation)             | iPad11,3   |
+--------------+---------------------------------------+------------+
```

### available percentiles for your apps
```
bundle exec exe/xcmagg percentiles --b yourapp1,yourapp2
```

```
+----------------+--------------------------------------------+
|                        yourapp1                             |
+----------------+--------------------------------------------+
| percentile     | id                                         |
+----------------+--------------------------------------------+
| Typical        | com.apple.dt.metrics.percentile.fifty      |
| Top Percentile | com.apple.dt.metrics.percentile.ninetyFive |
+----------------+--------------------------------------------+

+----------------+--------------------------------------------+
|                        yourapp2                             |
+----------------+--------------------------------------------+
| percentile     | id                                         |
+----------------+--------------------------------------------+
| Typical        | com.apple.dt.metrics.percentile.fifty      |
| Top Percentile | com.apple.dt.metrics.percentile.ninetyFive |
+----------------+--------------------------------------------+
```

### launch time metrics for an app
```
bundle exec exe/xcmagg metrics -s launchTime -b yourapp1 -d iPhone11,6
```

```
+-------+-------------+----------+----------------+
| Label | Version     | Device   | Percentile     |
+-------+-------------+----------+----------------+
| 0     | 1.0.0       | iPhone 8 | Typical        |
| 1     | 1.1.0       | iPhone 8 | Typical        |
| 2     | 1.3.0       | iPhone 8 | Typical        |
| 3     | 1.4.0       | iPhone 8 | Typical        |
| 4     | 1.5.0       | iPhone 8 | Typical        |
| 5     | 2.0.0       | iPhone 8 | Typical        |
+-------+-------------+----------+----------------+

700.0|                  
600.0|                  
500.0|          *       
400.0|          *       
300.0|    *  *  *  *  *  
200.0| *  *  *  *  *  *  
100.0| *  *  *  *  *  *  
  0.0+-------------------
       0  1  2  3  4  5  
 
Unit: ms

```


### Compare launch times between your apps
```
bundle exec exe/xcmagg latest -s launchTime -d iPhone11,6 -p com.apple.dt.metrics.percentile.ninetyFive
```

```
+-------+-----------------------------------+-------------+
| Label | Bundle ID                         | Version     |
+-------+-----------------------------------+-------------+
| 0     | yourapp1                          | 2.0.0       |
| 1     | yourapp2                          | 1.1.0       |
+-------+-----------------------------------+-------------+

700.0|    *              
600.0|    *              
500.0|    *     
400.0|    *  
300.0| *  * 
200.0| *  * 
100.0| *  * 
  0.0+------
       0  1 
 
Unit: ms

```

### Send the metrics to your log server with CSV format
```
bundle exec exe/xcmagg latest -s launchTime -d iPhone11,6 -p com.apple.dt.metrics.percentile.ninetyFive --f csv
```

```
Label,Bundle ID,Version,Point
0,yourapp1,2.0.0,698
1,yourapp2,1.1.0,300
```

## Run with Launchd to see changes over time

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
