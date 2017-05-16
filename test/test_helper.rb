$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'IntroText'
require 'nokogiri'

require 'minitest/autorun'

def html_fragment
  Nokogiri::HTML.fragment("<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?</p>")
end

def nested_html_fragment
  Nokogiri::HTML.fragment("<p><a>Lorem ipsum dolor sit amet</a>, consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?</p>")
end

def nested_adjacent_html_fragment
  Nokogiri::HTML.fragment("<p><a>Lorem</a>, <em>ipsum <strong>dolor</strong></em> sit amet consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?</p>")
end

def get_text_processor(opts = {})
  IntroText::TextProcessor.new(opts)
end
