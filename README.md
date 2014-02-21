[![Build Status](https://travis-ci.org/Strech/vines-backdoor.png?branch=master)](https://travis-ci.org/Strech/vines-backdoor)
[![Code Climate](https://codeclimate.com/github/Strech/vines-backdoor.png)](https://codeclimate.com/github/Strech/vines-backdoor)

# Vines::Backdoor

Allows you to authenticate and generate bosh session for Vines user by sigle request without password.
All that you need – a secret key from backdoor of your Vines

Standart http-bind flow requires 4 requests with 4 responses from Vines (last is binding result).
With vines-backdoor you need just 1 request and 1 response from Vines :triumph:

## Installation

Add this line to your application's Gemfile:

    gem 'vines-backdoor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vines-backdoor

## :warning: Attention :warning:

Never, ever, ever use this for external client authentication. This extension is only for internal server use

## Usage

Modify your vines config file

```ruby
# conf/config.rb

require 'vines/backdoor'

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

Send authentication and binding request in a batch

```html
<body xmlns="http://jabber.org/protocol/httpbind" xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0"
	  content="text/xml; charset=utf-8" rid="235205804" to="localhost" secure="true" wait="60" hold="1"
	  backdoor="my-secret-backdoor-key">
  <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="INTERNAL">user@localhost</auth>
  <bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
    <resource>pidgin</resource>
  </bind>
</body>
```

And get a successful response

```html
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
