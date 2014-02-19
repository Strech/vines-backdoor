# coding: utf-8
require "nokogiri"

module Vines
  module Backdoor
    class Gap
      BACKDOOR = "backdoor".freeze

      attr_reader :stream

      def initialize(stream)
        @stream = stream
      end

      def node(node)
        raise StreamErrors::NotAuthorized unless backdoor?(node)

        stream.start_session(node)
        Backdoor::Auth.new(stream).auth(node)
        Backdoor::Bind.new(stream).bind(node)

        advance(node)
      end

      private
      def advance(node)
        doc = Nokogiri::XML::Document.new
        result = doc.create_element('iq', 'id' => node['rid'], 'type' => 'result') do |el|
          el << doc.create_element('bind') do |bind|
            bind.default_namespace = Vines::Stream::Client::Bind::NS
            bind << doc.create_element('jid', stream.user.jid.to_s)
            bind << doc.create_element('sid', stream.id)
          end
        end

        stream.write(result)
      end

      def backdoor?(node)
        node[BACKDOOR] && node[BACKDOOR] == @stream.backdoor
      end
    end
  end
end
