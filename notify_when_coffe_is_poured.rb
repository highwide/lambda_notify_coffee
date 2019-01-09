require 'json'
require 'net/http'
require 'uri'

def lambda_handler(event:, context:)
  coffee_type = choose_coffee_type(event.dig('deviceEvent', 'buttonClicked', 'clickType'))

  url = slack_url
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.start do
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data(payload: generate_json(coffee_type))
    http.request(req)
  end
end

private

def choose_coffee_type(click_type)
  case click_type
  when 'SINGLE'
    'NORMAL'
  when 'DOUBLE'
    'DEPTH_ROASTED'
  when 'LONG'
    'ICE'
  else
    'NORMAL'
  end
end

def slack_url
  URI.parse(ENV['SLACK_URL'])
end

def generate_json(coffee_type)
  text, icon = generate_text_with_icon(coffee_type)

  {
    channel: ENV['SLACK_CHANNEL'],
    username: 'バリスタさん',
    text: text,
    icon_emoji: icon
  }.to_json
end

def generate_text_with_icon(coffee_type)
  case coffee_type
  when 'NORMAL'
    ['コーヒーを淹れましたよ〜', ':coffee:']
  when 'DEPTH_ROASTED'
    ['深煎りのコーヒーを淹れました(｀･ω･´)', ':fukaii:']
  when 'ICE'
    ['アイスコーヒーを淹れてみました！', ':ice_coffee:']
  else
    ['コーヒーが入りましたよ', ':coffee:']
  end
end

