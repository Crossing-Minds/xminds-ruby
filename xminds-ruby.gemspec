# frozen_string_literal: true

require_relative 'lib/xminds/ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'xminds-ruby'
  spec.version       = Xminds::Ruby::VERSION
  spec.authors       = ['Travis Hooper']
  spec.email         = ['travisdhooper@gmail.com']

  spec.summary       = 'Crossing Minds data science Ruby library and API client'
  spec.description   = ''
  spec.homepage      = 'https://github.com/Crossing-Minds/xminds-ruby'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to \'http://mygemserver.com\'"

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
