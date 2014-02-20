# coding: UTF-8

module Vines
  module Backdoor
    class Bind < Vines::Stream::Client::Bind
      def bind(node)
        @attempts += 1
        raise StreamErrors::NotAuthorized unless bind?(node)
        raise StreamErrors::PolicyViolation.new('max bind attempts reached') if @attempts > MAX_ATTEMPTS
        raise StanzaErrors::ResourceConstraint.new(fabricate_request(node), 'wait') if resource_limit_reached?

        stream.bind!(resource(node))
      end

      private
      def bind?(node)
        node.xpath('ns:bind', 'ns' => NS).any?
      end

      def resource(node)
        el = node.xpath('ns:bind/ns:resource', 'ns' => NS).first
        resource = el ? el.text.strip : ''
        generate = resource.empty? || !resource_valid?(resource) || resource_used?(resource)
        generate ? Vines::Kit.uuid : resource
      end

      def fabricate_request(node)
        doc = Document.new
        doc.create_element('iq') do |el|
          el['id'] = node['rid']
          el << node.xpath('ns:bind/ns:resource', 'ns' => NS).first
        end
      end
    end # class Bind
  end # module Backdoor
end # module Vines
