
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xc_metrics_aggregator/version"

Gem::Specification.new do |spec|
  spec.name          = "xc_metrics_aggregator"
  spec.version       = XcMetricsAggregator::VERSION
  spec.authors       = ["Yahoo Japan Corporation"]
  spec.email         = ["kahayash@yahoo-copr.jp"]

  spec.summary       = %q{AppleScript for Xcode Metrics Organizer}
  spec.description   = %q{XCMetricsAggregator aggregates metrics across all apps from Xcode Metrics Organizer by automating Xcode with AppleScript.}
  spec.homepage      = "https://github.com/yahoojapan/XCMetricsAggregator"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = ["xcmagg"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "etc"  
  spec.add_dependency "terminal-table"
  spec.add_dependency "ascii_charts"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "spec"
end
