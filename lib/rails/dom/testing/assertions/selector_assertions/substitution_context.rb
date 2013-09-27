class SubstitutionContext
  def initialize(substitute = '?')
    @substitute = substitute
    @regexes = []
  end

  def add_regex(regex)
    # Nokogiri doesn't like arbitrary values without quotes, hence inspect.
    return regex.inspect unless regex.is_a?(Regexp)
    @regexes.push(regex)
    last_id.to_s # avoid implicit conversions of Fixnum to String
  end

  def last_id
    @regexes.count - 1
  end

  def match(matches, attribute, id)
    matches.find_all { |node| node[attribute] =~ @regexes[id] }
  end

  def substitute!(selector, values)
    while !values.empty? && selector.index(@substitute)
      selector.sub!(@substitute, add_regex(values.shift))
    end
    selector
  end
end
