module Rails
  module Dom
    module Testing
      module Assertions
        autoload :DomAssertions, 'assertions/dom_assertions'
        autoload :SelectorAssertions, 'assertions/selector_assertions'

        extend ActiveSupport::Concern

        include DomAssertions
        include SelectorAssertions
      end
    end
  end
end