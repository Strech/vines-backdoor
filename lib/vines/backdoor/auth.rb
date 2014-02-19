# coding: UTF-8

module Vines
  module Backdoor
    class Auth < Vines::Stream::Client::Auth
      INTERNAL = "INTERNAL".freeze

      def auth(node)
        raise StreamErrors::NotAuthorized unless auth?(node)

        node = node.xpath('ns:auth', 'ns' => NS).first

        if node.text.empty?
          send_auth_fail(SaslErrors::MalformedRequest.new)
        elsif stream.authentication_mechanisms.include?(node[MECHANISM])
          if node[MECHANISM] == INTERNAL
            stream.user = authenticate(node.text) or raise StreamErrors::NotAuthorized
          end
        else
          send_auth_fail(SaslErrors::InvalidMechanism.new)
        end
      end

      private
      def auth?(node)
        node.xpath('ns:auth', 'ns' => NS).any?
      end

      def authenticate(jid)
        log.info("Authenticating user: %s" % jid)
        stream.storage.find_user(jid).tap do |user|
          log.info("Authentication succeeded (backdoor): %s" % user.jid) if user
        end
      rescue => e
        log.error("Failed to authenticate: #{e.to_s}")
        raise Vines::SaslErrors::TemporaryAuthFailure
      end
    end # class Auth
  end # module Backdoor
end # module Vines
