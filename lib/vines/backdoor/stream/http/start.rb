# coding: UTF-8

module Vines
  class Stream
    class Http
      class Start < State
        def node(node)
          raise StreamErrors::NotAuthorized unless body?(node)
          if session = Sessions[node['sid']]
            session.resume(stream, node)
          else

            if node['backdoor']
              backdoor = Vines::Backdoor::Gap.new(stream)
              backdoor.node(node)
            else
              stream.start(node)
              advance
            end
          end
        end
      end # class Start
    end # class Http
  end # class Stream
end # module Vines
