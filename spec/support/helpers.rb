# coding: utf-8
module Helpers
  def node(xml)
    xml = xml.strip.gsub(/\n|\s{2,}/, '')
    Nokogiri::XML(xml).root
  end

  def em
    EM.run do
      yield if block_given?
      EM.stop
    end
  end
end