# coding: utf-8
module Vines
  class Stream
    class Http < Client
      MECHANISMS = %w[PLAIN INTERNAL].freeze

      def backdoor(*args)
        config[:http].backdoor(*args)
      end

      def authentication_mechanisms
        MECHANISMS
      end

      def start_session(node)
        domain, type, hold, wait, rid = %w[to content hold wait rid].map {|a| (node[a] || '').strip }
        version = node.attribute_with_ns('version', NAMESPACES[:bosh]).value rescue nil

        @session.inactivity = 20
        @session.domain = domain
        @session.content_type = type unless type.empty?
        @session.hold = hold.to_i unless hold.empty?
        @session.wait = wait.to_i unless wait.empty?

        raise StreamErrors::UndefinedCondition.new('rid required') if rid.empty?
        raise StreamErrors::UnsupportedVersion unless version == '1.0'
        raise StreamErrors::ImproperAddressing unless valid_address?(domain)
        raise StreamErrors::HostUnknown unless config.vhost?(domain)
        raise StreamErrors::InvalidNamespace unless node.namespaces['xmlns'] == NAMESPACES[:http_bind]

        Sessions[@session.id] = @session
      end
    end # class Http
  end # class Stream
end # module Vines
