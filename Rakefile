# frozen_string_literal: true

require "bundler/gem_tasks"

task default: :ci

desc "Run continuous integration suite"
task :ci do
  ContinuousIntegration.run do |ci|
    ci.step "Tests: RSpec", "bundle exec rspec"
    ci.step "Style: Ruby", "bundle exec rubocop"
  end
end

desc "Run tests"
task :test do
  exec "bundle exec rspec"
end

desc "Run ruby linter"
task :lint do
  exec "bundle exec rubocop"
end

desc "Start an IRB console"
task :console do
  require "irb"
  require "bundler/setup"

  require_relative "lib/enum_fields"
  puts "Loading enum_fields v#{EnumFields::VERSION}"

  ARGV.clear
  IRB.start
end

################################################################################
## Continuous Integration
################################################################################

class ContinuousIntegration
  COLORS = {
    banner: "\e[1;33m",
    title: "\e[35m",
    subtitle: "\e[2m",
    success: "\e[32m",
    error: "\e[31m",
    reset: "\e[0m",
  }.freeze

  INDICATORS = {
    success: "\u2705",
    error: "\u274C",
  }.freeze

  def self.run(title = "Continuous Integration", subtitle = "Running tests, style checks, and security audits", &)
    ENV["CI"] = "true"

    ci = new
    ci.heading(title, subtitle, padding: false)
    ci.report(title, &)

    abort unless ci.success?
  end

  def initialize
    @results = []
  end

  def step(title, *command)
    heading(title, command.join(" "), type: :title)

    report(title) do
      @results << system(*command)
    end
  end

  def success?
    @results.all?
  end

  def failure(title, subtitle = nil)
    heading(title, subtitle, type: :error)
  end

  def heading(text, subtitle = nil, type: :banner, padding: true)
    echo("\n", type: type) if padding
    echo(text, type: type)
    echo(subtitle, type: :subtitle) if subtitle
    echo("\n", type: type) if padding
  end

  def echo(text, type:)
    puts "#{COLORS[type]}#{text}#{COLORS[:reset]}"
  end

  def report(title)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield self
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    formatted_duration = format("%.2fs", duration)

    if success?
      echo "\n#{INDICATORS[:success]} #{title} passed in #{formatted_duration}\n", type: :success
    else
      echo "\n#{INDICATORS[:error]} #{title} failed in #{formatted_duration}\n", type: :error
    end
  end
end
