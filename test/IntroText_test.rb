require 'test_helper'

class IntroTextTest < Minitest::Test
  def test_it_can_be_configured
    test_class = 'testing-class'
    test_type = 'div'
    processor = get_text_processor(wrap_class: test_class, wrap_type: test_type)
    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 5)

    assert test_fragment.children[0].children[0].inner_text == 'Lorem ipsum dolor sit amet, '
    assert test_fragment.children[0].children[0].attr('class') == test_class
    assert test_fragment.children[0].children[0].name == test_type
  end

  def test_it_wraps_the_first_n_words
    test_fragment = html_fragment
    processor = get_text_processor

    processor.style_first_n_words(test_fragment, 5)
    assert test_fragment.inner_text == 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maxime quod vitae quis voluptatibus neque possimus praesentium quae inventore, perferendis laborum, est laboriosam natus fuga maiores sapiente ad, optio illum necessitatibus?'
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor sit amet, "

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 8)
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor sit amet, consectetur adipisicing elit. "

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 3)
    assert test_fragment.children[0].children[0].inner_text == "Lorem ipsum dolor "

    test_fragment = html_fragment
    processor.style_first_n_words(test_fragment, 0)
    assert test_fragment.children.first.children.first.name == 'text'
  end

  def test_it_can_handle_links
    # Even though we specify 4 words to style, 5 should actually be styled due to their being contained
    # within a link tag.
    test_fragment = nested_html_fragment
    processor = get_text_processor(wrap_class: 'testing')
    processor.style_first_n_words(test_fragment, 4)
    assert test_fragment.children[0].children[0].name == 'a'
    assert test_fragment.children[0].children[0].children[0].name == 'span'
    assert test_fragment.children[0].children[0].children[0].inner_text.split(' ').length == 5
  end

  def test_adjacent_tags
    test_fragment = nested_adjacent_html_fragment
    processor = get_text_processor(wrap_class: 'testing')
    processor.style_first_n_words(test_fragment, 6)
    assert test_fragment.children[0].children[0].name == 'a'
    assert test_fragment.children[0].children[0].children[0].name == 'span'
    assert test_fragment.children[0].children[0].children[0].inner_text.split(' ').length == 1
  end
end
