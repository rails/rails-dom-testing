require 'active_support/concern'

begin
  gem "nokogiri", ">= 1.6"
  require 'nokogiri'
rescue LoadError => e
  raise LoadError, "Failed to load nokogiri gem. Add gem 'nokogiri', group: [:development, :test] to your Gemfile and run bundle install to enable rails-dom-helpers in your test environment.", e.backtrace
end

module Rails
  module Dom
    module Testing
      module Assertions
        autoload :DomAssertions, 'rails/dom/testing/assertions/dom_assertions'
        autoload :SelectorAssertions, 'rails/dom/testing/assertions/selector_assertions'

        extend ActiveSupport::Concern

        include DomAssertions
        include SelectorAssertions
      end
    end
  end
end
