require File.join(File.expand_path('../lib', __FILE__), 'bing-ads-reporting', 'version')

Gem::Specification.new do |gem|
  gem.name          = "bing-ads-reporting"
  gem.version       = BingAdsReporting::VERSION
  gem.authors       = ["Robert Borkowski"]
  gem.email         = ["robert.borkowski@forward3d.com"]
  gem.description   = %q{Bing Ads Reports}
  gem.summary       = %q{Allows easily pull reports from Bing Ads}
  gem.homepage      = "https://github.com/forward3d/bing-ads-reporting"

  gem.files         = [ 'lib/bing-ads-reporting.rb',
                        'lib/bing-ads-reporting/service.rb',
                        'lib/bing-ads-reporting/version.rb']

  gem.executables   = [] #gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = [] #gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'datebox', '~> 0.5.0'
  gem.add_dependency 'savon',   '~> 2.12.0'
  gem.add_dependency 'curb',    '~> 0.9.10'

  gem.add_development_dependency 'test-unit' , '~> 1.2.3'

  gem.license = 'MIT'
end
