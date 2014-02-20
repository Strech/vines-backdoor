# coding: utf-8
module Vines
  class Config
    class HttpPort
      def backdoor(secret_key = nil)
        if secret_key
          @settings[:backdoor_secret_key] = secret_key
        else
          @settings[:backdoor_secret_key]
        end
      end
    end # class HttpPort
  end # class Config
end # module Vines