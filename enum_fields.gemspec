# frozen_string_literal: true

require_relative 'lib/enum_fields/version'

Gem::Specification.new do |spec|
  spec.name     = 'enum_fields'
  spec.version  = EnumFields::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ['Kinnell Shah']
  spec.email    = ['kinnell@gmail.com']

  spec.summary     = 'enum_fields'
  spec.description = 'enum_fields'
  spec.homepage    = 'https://github.com/kinnell/enum_fields'
  spec.license     = 'MIT'

  spec.metadata['allowed_push_host']     = 'https://rubygems.pkg.github.com/kinnell'
  spec.metadata['github_repo']           = 'ssh://github.com/kinnell/enum_fields'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir[
    'lib/**/*',
    'Gemfile',
    '*.md'
  ]

  spec.executables << 'enum_fields'

  spec.require_paths = ['lib']
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')
  spec.required_rubygems_version = Gem::Requirement.new('>= 2.0')

  spec.add_dependency 'activesupport', '>= 6.0'
end
