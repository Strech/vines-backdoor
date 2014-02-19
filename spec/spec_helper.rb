# coding: utf-8

require "vines"
require "vines/backdoor"

module Support
  def node(xml)
    Nokogiri::XML(xml).root
  end

  def em
    EM.run do
      yield if block_given?
      EM.stop
    end
  end
end

# Disable vines logger
Class.new.extend(Vines::Log).log.level = Logger::FATAL

RSpec.configure do |config|
  config.formatter = :progress
  config.order = :random
  config.color = true

  include Support
end