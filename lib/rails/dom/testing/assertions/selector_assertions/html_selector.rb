require 'active_support/core_ext/module/attribute_accessors'
require_relative 'substitution_context'

class HTMLSelector #:nodoc:
  attr_reader :css_selector, :tests, :message

  def initialize(values, previous_selection = nil, &root_fallback)
    @values = values
    @root, @css_selector, @selector = extract_root_and_selectors(previous_selection, &root_fallback)
    @tests = extract_equality_tests
    @message = @values.shift

    if @values.shift
      raise ArgumentError, "Not expecting that last argument, you either have too many arguments, or they're the wrong type"
    end
  end

  def selecting_no_body? #:nodoc:
    # Nokogiri gives the document a body element. Which means we can't
    # run an assertion expecting there to not be a body.
    @selector == 'body' && @tests[:count] == 0
  end

  def select
    nodeset =
      if @selector.present?
        @root.css(@selector, context)
      elsif @root.is_a? Nokogiri::XML::NodeSet
        @root
      else
        Nokogiri::XML::NodeSet.new(@root.document, [@root])
      end

    filter nodeset
  end

  private

  NO_STRIP = %w{pre script style textarea}

  mattr_reader(:context) { SubstitutionContext.new }

  def filter(matches)
    match_with = tests[:text] || tests[:html]
    return matches if matches.empty? || !match_with

    content_mismatch = nil
    text_matches = tests.has_key?(:text)
    regex_matching = match_with.is_a?(Regexp)

    remaining = matches.reject do |match|
      # Preserve markup with to_s for html elements
      content = text_matches ? match.text : match.children.to_s

      content.strip! unless NO_STRIP.include?(match.name)
      content.sub!(/\A\n/, '') if text_matches && match.name == "textarea"

      next if regex_matching ? (content =~ match_with) : (content == match_with)
      content_mismatch ||= sprintf("<%s> expected but was\n<%s>.", match_with, content)
      true
    end

    @message ||= content_mismatch if remaining.empty?
    Nokogiri::XML::NodeSet.new(matches.document, remaining)
  end

  def extract_root(previous_selection)
    possible_root = @values.first

    if possible_root == nil
      raise ArgumentError, 'First argument is either selector or element ' \
        'to select, but nil found. Perhaps you called assert_dom with ' \
        'an element that does not exist?'
    elsif possible_root.respond_to?(:css)
      @values.shift # remove the root, so selector is the first argument
      possible_root
    elsif previous_selection
      previous_selection
    end
  end

  def extract_root_and_selectors(previous_selection, &root_fallback)
    root = extract_root(previous_selection)

    if @values.first.is_a? String
      selector = @values.shift

      [ root || root_fallback.call, context.substitute!(selector, @values.dup, true),  context.substitute!(selector, @values) ]
    elsif root.present?
      [ root ]
    else
      raise ArgumentError, "Expecting a selector or node as the first argument"
    end
  end

  def extract_equality_tests
    comparisons = {}
    case comparator = @values.shift
    when Hash
      comparisons = comparator
    when String, Regexp
      comparisons[:text] = comparator
    when Integer
      comparisons[:count] = comparator
    when Range
      comparisons[:minimum] = comparator.begin
      comparisons[:maximum] = comparator.end
    when FalseClass
      comparisons[:count] = 0
    when NilClass, TrueClass
      comparisons[:minimum] = 1
    else raise ArgumentError, "I don't understand what you're trying to match"
    end

    # By default we're looking for at least one match.
    if comparisons[:count]
      comparisons[:minimum] = comparisons[:maximum] = comparisons[:count]
    else
      comparisons[:minimum] ||= 1
    end
    comparisons
  end
end
