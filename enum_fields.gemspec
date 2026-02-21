# frozen_string_literal: true

require_relative "lib/enum_fields/version"

Gem::Specification.new do |spec|
  spec.name = "enum_fields"
  spec.version = EnumFields::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Kinnell Shah"]
  spec.email = ["kinnell@gmail.com"]

  spec.summary = "Enhanced enum-like fields for ActiveRecord models with metadata support"
  spec.description = <<~TEXT
    A Rails gem that provides enum-like functionality with support for metadata properties (label, icon, color, tooltip) and automatic scopes, validations, and inquiry methods.
  TEXT

  spec.homepage = "https://github.com/kinnell/enum_fields"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["github_repo"] = "ssh://github.com/kinnell/enum_fields"
  spec.metadata["source_code_uri"] = "https://github.com/kinnell/enum_fields"
  spec.metadata["changelog_uri"] = "https://github.com/kinnell/enum_fields/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/kinnell/enum_fields/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "LICENSE", "*.md"]

  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.6")
  spec.required_rubygems_version = Gem::Requirement.new(">= 2.0")

  spec.add_dependency "activerecord", ">= 6.0", "< 9.0"
  spec.add_dependency "activesupport", ">= 6.0", "< 9.0"
end
