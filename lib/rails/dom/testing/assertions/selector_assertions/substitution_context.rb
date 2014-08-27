class SubstitutionContext
  def initialize
    @substitute = '?'
    @regexes = []
  end

  def substitute!(selector, values)
    while !values.empty? && substitutable?(values.first) && selector.index(@substitute)
      selector.sub! @substitute, add_regex(values.shift)
    end
    selector
  end

  def match(matches, attribute, id)
    matches.find_all { |node| node[attribute] =~ @regexes[id] }
  end

  private
    def add_regex(regex)
      if regex.is_a?(Regexp)
        @regexes.push(regex)
        last_id.to_s # avoid implicit conversions of Fixnum to String
      else
        regex.inspect # Nokogiri doesn't like arbitrary values without quotes, hence inspect.
      end
    end

    def last_id
      @regexes.count - 1
    end

    def substitutable?(value)
      value.is_a?(String) || value.is_a?(Regexp)
    end
end
