# frozen_string_literal: true

require "nokogiri"
require "active_support"

require_relative "assertions/dom_assertions"
require_relative "assertions/selector_assertions"

module Rails
  module Dom
    module Testing
      module Assertions
        include DomAssertions
        include SelectorAssertions
      end
    end
  end
end
