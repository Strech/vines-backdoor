[![Build Status](https://travis-ci.org/Strech/vines-backdoor.png?branch=master)](https://travis-ci.org/Strech/vines-backdoor)

# Vines::Backdoor

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'vines-backdoor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vines-backdoor

## :warning: Attention :warning:

Never, never use this for client requests, only internal server use

## Usage

Modify your vines config file

```ruby
# conf/config.rb

require 'vines/backdoor'

# ...

# http bind section
http '0.0.0.0', 5280 do
  bind '/http-bind'
  max_stanza_size 65536
  max_resources_per_account 5
  root 'web'
  vroute ''
  backdoor 'my-secret-backdoor-key'
end
```

Now http service accept extended requests with some extra data in it.
All response messages (errors and success responses) are RFC compatible

```html
<!-- request -->
<body xmlns="http://jabber.org/protocol/httpbind" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"
	  content="text/xml; charset=utf-8" rid="235205804" to="localhost" secure="true" wait="60" hold="1"
	  backdoor="my-secret-backdoor-key">
  <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
  <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
    <resource>pidgin</resource>
  </bind>
</body>

<!-- response -->
<iq type="result" id="235205804">
  <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
    <jid>user@localhost/pidgin</jid>
    <sid>f27c71df-f124-4829-b415-5855b8c04109</sid>
  </bind>
</iq>
```

## Contributing

1. Fork it ( http://github.com/Strech/vines-backdoor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
