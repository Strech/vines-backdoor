# coding: utf-8
require "spec_helper"

describe Vines::Backdoor::Auth do
  let(:klass) { described_class.new(stream) }
  let(:storage) { double("Storage") }
  let(:stream) do
    double("Stream", storage: storage,
      authentication_mechanisms: ["INTERNAL"]).as_null_object
  end

  context "when missing auth namespace" do
    let(:xml) { node(%q{<body><auth mechanism="INTERNAL">user@localhost</auth></body>}) }

    it { expect { klass.auth(xml) }.to raise_error Vines::StreamErrors::NotAuthorized }
  end

  context "when used unknown mechanism" do
    let(:xml) do
      node(%q{<body>
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="FOO">user@localhost</auth>
      </body>})
    end

    after { klass.auth(xml) }

    it { expect(stream).to receive(:error).with(kind_of Vines::SaslErrors::InvalidMechanism) }
  end

  context "when no username is given" do
    let(:xml) do
      node(%q{<body>
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL"></auth>
      </body>})
    end

    after { klass.auth(xml) }

    it { expect(stream).to receive(:error).with(kind_of Vines::SaslErrors::MalformedRequest) }
  end

  context "when user not found" do
    let(:xml) do
      node(%q{<body>
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
      </body>})
    end

    before { storage.stub(:find_user).with("user@localhost").and_return nil }

    it { expect { klass.auth(xml) }.to raise_error Vines::StreamErrors::NotAuthorized }
  end

  context "when user is authenticated" do
    let(:user) { double("User", jid: "user@localhost") }
    let(:xml) do
      node(%q{<body>
        <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
      </body>})
    end

    before { storage.stub(:find_user).with("user@localhost").and_return user }
    after { klass.auth(xml) }

    it { expect(stream).to receive(:user=).with(user) }
  end
end