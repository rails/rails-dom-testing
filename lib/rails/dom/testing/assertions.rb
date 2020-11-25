require 'nokogiri'
require 'rails/dom/testing/assertions/dom_assertions'
require 'rails/dom/testing/assertions/selector_assertions'

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
