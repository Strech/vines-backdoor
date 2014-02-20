# coding: utf-8
require "spec_helper"

describe Vines::Backdoor::Bind do
  let(:klass) { described_class.new(stream) }
  let(:storage) { double("Storage") }
  let(:stream) { double("Stream", storage: storage) }

  context "when missing bind namespace" do
    let(:xml) { node(%q{<body><bind><resource>pidgin</resource></bind></body>}) }

    it { expect { klass.bind(xml) }.to raise_error Vines::StreamErrors::NotAuthorized }
  end

  context "when max attemps is reached" do
    let(:xml) do
      node(%q{<body>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end

    before { stub_const("Vines::Stream::Client::Bind::MAX_ATTEMPTS", 0) }

    it { expect { klass.bind(xml) }.to raise_error Vines::StreamErrors::PolicyViolation }
  end

  context "when resource limit is reached" do
    let(:xml) do
      node(%q{<body>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end

    before { klass.stub(resource_limit_reached?: true) }

    it { expect { klass.bind(xml) }.to raise_error Vines::StanzaErrors::ResourceConstraint }
  end

  context "when bind session with given resource" do
    let(:xml) do
      node(%q{<body>
        <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
          <resource>pidgin</resource>
        </bind></body>})
    end

    before do
      klass.stub(resource_valid?: true)
      klass.stub(resource_limit_reached?: false)
      klass.stub(:resource_used?).with("pidgin").and_return false
    end
    after { klass.bind(xml) }

    it { expect(stream).to receive(:bind!).with("pidgin") }
  end

  context "when bind session with generated resource" do
    let(:xml) { node(%q{<body><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/></body>}) }

    before do
      klass.stub(resource_valid?: true)
      klass.stub(resource_limit_reached?: false)
    end
    after { klass.bind(xml) }

    it do
      expect(Vines::Kit).to receive(:uuid).and_return "random-resource"
      expect(stream).to receive(:bind!).with("random-resource")
    end
  end
end