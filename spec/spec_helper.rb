# frozen_string_literal: true

require 'pathname'

require 'enum_fields'

SPEC_PATH = Pathname.getwd.join('spec').freeze
SPEC_PATH.glob('support/**/*.rb').each { |file| require file }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.pattern = '**/*.spec.rb'
end
