# coding: utf-8

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

      # TODO : Сделать генерацию через Nokogiri?
      def advance(node)
        response = %Q{
        <iq type="result" id="#{node['rid']}">
          <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
            <jid>#{stream.user.jid}</jid>
            <sid>#{stream.id}</sid>
          </bind>
        </iq>
        }

        stream.write(response)
      end

      private
      def backdoor?(node)
        node[BACKDOOR] && node[BACKDOOR] == @stream.backdoor
      end
    end
  end
end