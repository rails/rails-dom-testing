# frozen_string_literal: true

module Rails
  module Dom
    module Testing
      module Assertions
        module SelectorAssertions
          class SubstitutionContext # :nodoc:
            # Nokogiri 1.19.5+ applies CSS escapes inside string arguments to
            # custom pseudo-classes, so a Regexp's backslashes must be escaped
            # to reach the matcher intact. Older versions pass them through.
            CSS_STRING_ESCAPES = !Nokogiri::CSS.xpath_for(%q{a:match('x','\\\\')}).first.include?("\\\\")
            private_constant :CSS_STRING_ESCAPES

            def initialize
              @substitute = "?"
            end

            def substitute!(selector, values, format_for_presentation = false)
              selector.gsub @substitute do |match|
                next match[0] if values.empty? || !substitutable?(values.first)
                matcher_for(values.shift, format_for_presentation)
              end
            end

            def match(matches, attribute, matcher)
              matches.find_all { |node| node[attribute] =~ Regexp.new(matcher) }
            end

            private
              def matcher_for(value, format_for_presentation)
                # Nokogiri doesn't like arbitrary values without quotes, hence inspect.
                if format_for_presentation
                  value.inspect # Avoid to_s so Regexps aren't put in quotes.
                elsif value.is_a?(Regexp)
                  source = value.to_s
                  source = source.gsub(/[\\"]/) { |char| "\\#{char}" } if CSS_STRING_ESCAPES
                  "\"#{source}\""
                else
                  value.to_s.inspect
                end
              end

              def substitutable?(value)
                [ Symbol, Numeric, String, Regexp ].any? { |type| value.is_a? type }
              end
          end
        end
      end
    end
  end
end
