# coding: utf-8
if ENV["COV"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "vines"
require "vines/backdoor"

# Disable vines logger
Class.new.extend(Vines::Log).log.level = Logger::FATAL
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.formatter = :progress
  config.order = :random
  config.color = true

  include Helpers
end