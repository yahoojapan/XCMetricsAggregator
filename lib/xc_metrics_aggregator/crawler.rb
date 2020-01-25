require 'open3'

module XcMetricsAggregator
    ROOT_DIR = File.expand_path("..", __dir__)
    APPLE_SCRIPT_EXECUTION = "osascript"
    APPLE_SCRIPT_FILE = "xcode_metrics_automation.applescript"

  class Crawler
    def self.execute
        script_fullpath = File.join(ROOT_DIR, APPLE_SCRIPT_FILE)
        command ="#{APPLE_SCRIPT_EXECUTION} #{script_fullpath}"
        Open3.popen3(command) do |i, o, e, w|
          o.each do |line| puts line end
          e.each do |line| puts line end
          puts w.value
        end
    end
  end
end