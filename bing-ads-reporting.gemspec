require File.join(File.expand_path('../lib', __FILE__), 'bing-ads-reporting', 'version')

Gem::Specification.new do |gem|
  gem.name          = 'bing-ads-reporting'
  gem.version       = BingAdsReporting::VERSION
  gem.authors       = ['Robert Borkowski', 'Mohamed Osama']
  gem.email         = ['robert.borkowski@forward3d.com', 'oss@findhotel.net']
  gem.description   = %q{Bing Ads Reports}
  gem.summary       = %q{Easily pulls reports from Bing Ads API}
  gem.homepage      = 'https://github.com/forward3d/bing-ads-reporting'

  gem.files         = [ 'lib/bing-ads-reporting.rb',
                        'lib/bing-ads-reporting/service.rb',
                        'lib/bing-ads-reporting/version.rb']

  gem.executables   = [] #gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = [] #gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'datebox'
  gem.add_dependency 'savon'
  gem.add_dependency 'curb'

  gem.license = 'MIT'
end
