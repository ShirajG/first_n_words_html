module IntroText
  class TextProcessor
    attr_accessor :wrap_class, :wrap_type

    def initialize(options = {})
      @wrap_class = options.fetch(:wrap_class, '')
      @wrap_type = options.fetch(:wrap_type, 'span')
    end

    def wrap_content child_node, word_count
      words = child_node.text
      words_to_wrap = ""
      words.split(' ').each do |word|
        if word_count <= 0
          break
        end

        words_to_wrap += words.slice!(0..(words.lstrip.index(' ') ? words.lstrip.index(' ') : -1))
        # Don't count a ',' by itself as a word. Can lead to the count being off when following a link.
        unless [','].include?(word)
          word_count -= 1
        end

        # If a period appears, stop styling any further.
        # Only exception is if styling link text, the whole link should be styled.
        if word[-1] == '.'
          unless ( tag_exceptions & child_node.ancestors.map(&:name)).any? ||
                 early_end_exceptions.include?(word.sub(/"|'|“/,'').strip.downcase)
              word_count = 0
          end
        end
      end

      child_node.content = words
      child_node.before(Nokogiri::HTML.fragment("#{section_start_tag(words_to_wrap)}"))
      # Return word count because we need to keep track of it in further loops.
      word_count
    end

    def wrap_embedded_tags(child_node, word_count)
      if word_count == 0
        return 0
      end

      child_node.children.each do |embedded_node|
        if embedded_node.name == 'text'
          word_count = wrap_content(embedded_node, word_count)
        elsif embedded_node.children != nil
          wrap_embedded_tags(embedded_node, word_count)
        end
      end

      return word_count
    end

    def style_first_n_words(graf, word_count, options = {})
      graf.children.each do |child_node|
        if word_count <= 0
          if child_node.name == 'text' && early_end_characters.include?(child_node.text[0])
            # Fine tuning tweak, always style certain trailing punctuations, even if we hit the word count
            child_node.content = child_node.text[1..-1]
            child_node.before(Nokogiri::HTML.fragment("#{section_start_tag(',')}"))
          end
          break
        end

        if child_node.name != 'text'
          # Links, Italics, and Bold are a special case, we don't want them getting partially styled.
          # We extend the word count by whatever the overflow would be.
          if tag_exceptions.include?(child_node.name)
            if word_count - child_node.text.split(' ').length < 0
              # Subtracting a negative number here.
              word_count -= word_count - child_node.text.split(' ').length
            end
          end

          # Drill down until we hit a text node, then wrap that.
          child_node.children.each do |embedded_child|
            if embedded_child.name != 'text' && embedded_child.children != nil
              word_count = wrap_embedded_tags(embedded_child, word_count)
            else
              word_count = wrap_content(embedded_child, word_count)
            end
          end
        else
          word_count = wrap_content(child_node, word_count)
        end
      end
    end

    def section_start_tag(content)
      if @wrap_class != ""
        "<#{@wrap_type} class=\"#{@wrap_class}\">#{content}</#{@wrap_type}>"
      else
        "<#{@wrap_type}>#{content}</#{@wrap_type}>"
      end
    end

    def early_end_exceptions
      [
        'mr.', 'ms.', 'dr.', 'mrs.', 'a.', 'b.', 'c.', 'd.', 'e.', 'f.', 'g.', 'h.',
        'i.', 'j.', 'k.', 'l.', 'm.', 'n.', 'o.', 'p.', 'q.', 'r.', 's.', 't.', 'u.',
        'v.', 'w.', 'x.', 'y.', 'z.', 'u.s.', 'u.s.a', 'm.b.a.', 'ph.d.', 'e.u.',
        'no.', 'vs.', 'u.k.'
      ]
    end

    def tag_exceptions
      ['a', 'em', 'strong']
    end

    def early_end_characters
      [',','.']
    end
  end
end
