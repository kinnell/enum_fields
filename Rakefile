# frozen_string_literal: true

require 'bundler/gem_tasks'

task default: :test

desc 'Run tests'
task :test do
  exec 'bundle exec rspec'
end

desc 'Run ruby linter'
task :lint do
  exec 'bundle exec rubocop'
end

desc 'Start an IRB console'
task :console do
  require 'irb'
  require 'bundler/setup'

  require_relative 'lib/enum_fields'
  puts "Loading enum_fields v#{EnumFields::VERSION}"

  ARGV.clear
  IRB.start
end
