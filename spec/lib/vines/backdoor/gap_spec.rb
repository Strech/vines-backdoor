# coding: utf-8
require "spec_helper"

describe Vines::Backdoor::Gap do
  let(:klass) { described_class.new(stream) }
  let(:storage) { double("Storage") }
  let(:stream) { double("Stream", storage: storage).as_null_object }

  context "when backdoor attribute is missing" do
    let(:xml) do
      node(%q{<body>
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end

    it { expect { klass.node(xml) }.to raise_error Vines::StreamErrors::NotAuthorized }
  end

  context "when backdoor attribute is wrong" do
    let(:xml) do
      node(%q{<body backdoor="12345">
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end

    before { stream.stub(backdoor: 9000) }

    it { expect { klass.node(xml) }.to raise_error Vines::StreamErrors::NotAuthorized }
  end

  context "when user is authenticated and session is binded" do
    let(:user) { double("User", jid: "user@localhost/pidgin") }
    let(:xml) do
      node(%q{<body rid="100500" backdoor="9000">
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end
    let(:expected) do
      node(%q{<iq id="100500" type="result">
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <jid>user@localhost/pidgin</jid>
          <sid>abcde-12345-fghijk-6789-xyz</sid>
        </bind></iq>})
    end

    before do
      stream.stub(backdoor: "9000")
      stream.stub(authentication_mechanisms: ["INTERNAL"])
      stream.stub(user: user)
      stream.stub(id: "abcde-12345-fghijk-6789-xyz")

      storage.stub(:find_user).with("user@localhost").and_return user

      Vines::Backdoor::Bind.any_instance.stub(resource_valid?: true)
      Vines::Backdoor::Bind.any_instance.stub(resource_limit_reached?: false)
    end
    after { klass.node(xml) }

    it do
      expect(stream).to receive(:write) do |response|
        expect(response.to_s).to eq expected.to_s
      end
    end
  end
end