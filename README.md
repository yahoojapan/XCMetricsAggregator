![](./assets/XCMetricsAggregator.png)

## What's this?

XCMetricsAggregator aggregates metrics data from [Xcode Metrics Organizer](https://help.apple.com/xcode/mac/current/#/devb642b28ac) with AppleScript. 

It also processes the raw data on your mac device to organize them as table or chart.

You can check how to use Xcode Metrics Organizer in WWDC 2019 session below.

- [Improving Battery Life and Performance - WWDC 2019](https://developer.apple.com/videos/play/wwdc2019/417/)

## Setup

1. Install Xcode 11.x from App Store or the following link

https://developer.apple.com/download/more/

2. Login with your Apple ID on Accounts preferences in Xcode

<img width="400" alt="スクリーンショット 0002-02-09 18 32 32" src="https://user-images.githubusercontent.com/18320004/74100072-1b04b300-4b6e-11ea-97e0-32239898846d.png">

3. check Accessibility setting in Security & Privacy. Script Editor, System Events and Terminal needs to be checked.

<img width="400" alt="Screen Shot 0002-02-10 at 0 34 47" src="https://user-images.githubusercontent.com/18320004/74105018-8c0f8f00-4b9d-11ea-9008-c1f166876b4a.png">



4. Install XCMetricsAggregator

```
gem install xc_metrics_aggregator
```


## Getting Started
There are 2 kinds of command.

- manupulating Xcode automatically
- processing raw json files for metrics data

"crowl" command download the json files with Xcode, and the others process them.

First of all, You need to download Xcode Metrics Organizer's raw data on your mac with "crowl" command.

### Available feature List
```
xcmagg help
```

### Downloading metrics data 
```
xcmagg crowl
```

This command launches Xcode automatically, and operates the mouse. 

If you interrupt the crowling, input Ctrl + C on the terminal.


### Application lookup in metrics data
```
xcmagg apps
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

### Available devices for your apps
```
xcmagg devices --b yourapp1,yourapp2
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

### Available percentiles for your apps
```
xcmagg percentiles --b yourapp1,yourapp2
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

### Checking available metricses

```
xcmagg sections -b yourapp1
```

```
+--------------+---------------+--------------+
|                  yourapp1                   |
+--------------+---------------+--------------+
| category     | section       | unit         |
+--------------+---------------+--------------+
| performance  | hangRate      | seconds/hour |
|              | launchTime    | ms           |
|              | peakMemory    | MB           |
|              | averageMemory | MB           |
| diskUsage    | diskWrites    | MB           |
| batteryUsage | allActivity   | seconds      |
|              | batteryUsage  | %/day        |
|              | onScreen      | %            |
|              | background    | %            |
+--------------+---------------+--------------+
```

### Launch time metrics for an app
```
xcmagg metrics -s launchTime -b yourapp1 -d iPhone11,6
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


### Comparison of LaunchTime between your apps
```
xcmagg latest -s launchTime -d iPhone11,6 -p com.apple.dt.metrics.percentile.ninetyFive
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

### Outputting the latest LaunchTime as CSV format
```
xcmagg latest -s launchTime -d iPhone11,6 -p com.apple.dt.metrics.percentile.ninetyFive -f csv
```

```
Label,Bundle ID,Version,Point
0,yourapp1,2.0.0,698
1,yourapp2,1.1.0,300
```

You can send it to your log server

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
