require File.join(File.expand_path('lib', __dir__), 'bing-ads-reporting', 'version')

Gem::Specification.new do |gem|
  gem.name          = 'bing-ads-reporting'
  gem.version       = BingAdsReporting::VERSION
  gem.authors       = ['Robert Borkowski']
  gem.email         = ['robert.borkowski@forward3d.com']
  gem.description   = 'Bing Ads Reports'
  gem.summary       = 'Allows easily pull reports from Bing Ads'
  gem.homepage      = 'https://github.com/forward3d/bing-ads-reporting'

  gem.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  end

  gem.executables   = [] # gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = [] # gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'httparty', '~> 0.17.0'
  gem.add_dependency 'datebox',  '~> 0.5.0'
  gem.add_dependency 'oauth2',   '~> 1.4.1'
  gem.add_dependency 'savon',    '~> 2.12.0'

  gem.add_development_dependency 'reek', '~> 5.4.0'
  gem.add_development_dependency 'rspec', '~> 3.4.0'
  gem.add_development_dependency 'rubocop', '~> 0.70.0'
  gem.add_development_dependency 'rubocop-performance', '~> 1.3.0'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.33.0'

  gem.license = 'MIT'
end
