require 'test_helper'
require 'nokogiri'
include IntroText

class IntroTextTest < Minitest::Test
  def html_fragment
    Nokogiri::HTML.fragment("<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?</p>")
  end

  def test_it_can_be_configured
    assert true
  end

  def test_it_wraps_the_first_n_words
    test_fragment = html_fragment
    processor = TextProcessor.new

    processor.style_first_n_words(test_fragment, 5)
    assert test_fragment.inner_text == 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?'
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor sit amet, "

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 8)
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor sit amet, consectetur adipisicing elit. "

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 3)
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor "
    puts test_fragment

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 0)
    assert test_fragment.children.first.children.first.name == 'text'
  end
end
