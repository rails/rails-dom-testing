# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails/dom/testing/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-dom-testing"
  spec.version       = Rails::Dom::Testing::VERSION
  spec.authors       = ["Rafael Mendonça França", "Kasper Timm Hansen"]
  spec.email         = ["rafaelmfranca@gmail.com", "kaspth@gmail.com"]
  spec.summary       = %q{ Dom and Selector assertions for Rails applications }
  spec.description   = %q{ This gem can compare doms and assert certain elements exists in doms using Nokogiri. }
  spec.homepage      = "https://github.com/rails/rails-dom-testing"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "MIT-LICENSE", "CHANGELOG.md"]
  spec.test_files    = Dir["test/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", ">= 1.8.1"
  spec.add_dependency "activesupport",  ">= 4.2.0"

  spec.add_development_dependency "bundler", ">= 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
