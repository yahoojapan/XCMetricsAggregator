use AppleScript version "2.4"
use scripting additions
use framework "Foundation"
use framework "ApplicationServices"
use framework "Quartz"


tell application "Xcode"
	activate
	tell application "System Events"
		tell process "Xcode"
			my displayOrganizer()
			delay 1
			
			my arrangePositionOfWindow()
			my clickRadioButtonOfMetricsViewer()
			
			set total_row_list to my getAllAppsFromTable()
			set visible_row_list to my getVisibleAppsFromTable()
			
			set total_row_count to count of total_row_list
			set visible_row_count to count of visible_row_list
			
			tell my NumberOfScrolling to calculate(total_row_count, visible_row_count)
			set start_pos to 1
			
			repeat result of NumberOfScrolling times
				my scrollDownForScrollingToTop()
			end repeat
			
			repeat result of NumberOfScrolling times
				tell my TableRowsClicker to calculateVisibleRows()
				tell my TableRowsClicker to clickStepByStep(start_pos)
				
				my scrollUp()
				delay 1
				
				set start_pos to start_pos + (row_count_in_scroll of TableRowsClicker)
			end repeat
		end tell
	end tell
end tell

-- Script Object

script TableRowsClicker
	property row_list_in_scroll : []
	property row_count_in_scroll : 0
	
	on calculateVisibleRows()
		tell application "System Events"
			tell process "Xcode"
				set my row_list_in_scroll to value of attribute "AXVisibleRows" of table 1 of scroll area 1 of splitter group 1 of window 1
				set my row_count_in_scroll to (count of row_list_in_scroll) - 1
			end tell
		end tell
	end calculateVisibleRows
	
	on clickStepByStep(start_pos)
		tell application "System Events"
			tell process "Xcode"
				
				set end_pos to start_pos + (my row_count_in_scroll)
				
				repeat with elem_pos from start_pos to end_pos by 1
					if elem_pos > my total_row_count then
						exit repeat
					end if
					
					set row_elem to my getRowElement(elem_pos)
					set pos to position of row_elem
					my clickAt(item 1 of pos, item 2 of pos)
					
					my waitForDownloading()
				end repeat
				
			end tell
		end tell
	end clickStepByStep
	
	on getRowElement(pos)
		tell application "System Events"
			tell process "Xcode"
				return row pos of table 1 of scroll area 1 of splitter group 1 of window 1
			end tell
		end tell
	end getRowElement
	
	on waitForDownloading()
		tell application "System Events"
			tell process "Xcode"
				repeat 100 times
					delay 1
					if exists static text 1 of splitter group 0 of splitter group 0 of window 1 then
						set label to value of static text 1 of splitter group 0 of splitter group 0 of window 1
					else
						exit repeat
					end if
					
					log label
					if my checkIfDownloadedState(label) then
						exit repeat
					end if
				end repeat
				
			end tell
		end tell
	end waitForDownloading
	
	on checkIfDownloadedState(label)
		return label = "No Metrics" or label = "Last Updated Today" or label = "Unable to Read Metrics" or label begins with "An error occurred"
	end checkIfDownloadedState
end script

script NumberOfScrolling
	property result : 0
	
	on calculate(total_row_count, visible_row_count)
		tell application "System Events"
			tell process "Xcode"
				set scroll_div to total_row_count div visible_row_count
				set scroll_mod to total_row_count mod visible_row_count
				
				
				if 0 < scroll_mod then
					set my result to scroll_div + 1
				else
					set my result to scroll_div
				end if
			end tell
		end tell
	end calculate
end script

-- Functions

on scrollDownForScrollingToTop()
	tell application "System Events"
		tell process "Xcode"
			perform action "AXScrollDownByPage" of scroll area 1 of splitter group 1 of window 1
		end tell
	end tell
end scrollDownForScrollingToTop

on scrollUp()
	tell application "System Events"
		tell process "Xcode"
			perform action "AXScrollUpByPage" of scroll area 1 of splitter group 1 of window 1
		end tell
	end tell
end scrollUp

on displayOrganizer()
	tell application "System Events"
		tell process "Xcode"
			click menu item "Organizer" of menu 1 of menu bar item "Window" of menu bar 1
		end tell
	end tell
end displayOrganizer

on arrangePositionOfWindow()
	tell application "Finder"
		set screen_height to (do shell script "system_profiler SPDisplaysDataType | awk '/Resolution/{print $4}'")
	end tell
	
	tell application "System Events"
		tell process "Xcode"
			set position of window 1 to {0, 0}
			set size of window 1 to {300, screen_height}
		end tell
	end tell
end arrangePositionOfWindow

on clickRadioButtonOfMetricsViewer()
	tell application "System Events"
		tell process "Xcode"
			click radio button 4 of radio group 1 of group 1 of toolbar 1 of window 1
		end tell
	end tell
end clickRadioButtonOfMetricsViewer

on getAllAppsFromTable()
	tell application "System Events"
		tell process "Xcode"
			set total_row_list to row of table 1 of scroll area 1 of splitter group 1 of window 1
		end tell
	end tell
	return total_row_list
end getAllAppsFromTable

on getVisibleAppsFromTable()
	tell application "System Events"
		tell process "Xcode"
			set visible_row_list to value of attribute "AXVisibleRows" of table 1 of scroll area 1 of splitter group 1 of window 1
		end tell
	end tell
	return visible_row_list
end getVisibleAppsFromTable


on clickAt(newX, newY)
	
	set pt to current application's CGPointZero
	set x of pt to newX
	set y of pt to newY
	
	current application's CGPostMouseEvent(pt, 1, 1, 1)
	current application's CGPostMouseEvent(pt, 1, 1, 0)
	
end clickAt
