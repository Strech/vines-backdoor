require "spec_helper"

describe Vines::Stream::Http::Start do
  context "when backdoor attribute present" do
    let(:start) { described_class.new(stream) }
    let(:xml) { node(%q{<body xmlns="http://jabber.org/protocol/httpbind" rid="42" backdoor="12345"/>}) }
    let(:gap) { double("Backdoor gap").as_null_object }
    let(:stream) { double("Stream", backdoor: "12345") }

    after { em { start.node(xml) } }

    it do
      expect(Vines::Backdoor::Gap).to receive(:new).with(stream).and_return gap
      expect(gap).to receive(:node).with(xml)
    end
  end
end