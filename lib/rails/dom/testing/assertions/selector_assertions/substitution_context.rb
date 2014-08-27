class SubstitutionContext
  def initialize
    @substitute = '?'
    @regexes = []
  end

  def substitute!(selector, values)
    while !values.empty? && substitutable?(values.first) && selector.index(@substitute)
      selector.sub! @substitute, substitution_id_for(values.shift)
    end
  end

  def match(matches, attribute, substitution_id)
    matches.find_all { |node| node[attribute] =~ @regexes[substitution_id] }
  end

  private
    def substitution_id_for(value)
      if value.is_a?(Regexp)
        @regexes << value
        @regexes.size - 1
      else
        value
      end.inspect # Nokogiri doesn't like arbitrary values without quotes, hence inspect.
    end

    def substitutable?(value)
      value.is_a?(String) || value.is_a?(Regexp)
    end
end
