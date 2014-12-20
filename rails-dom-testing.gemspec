# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails/dom/testing/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-dom-testing"
  spec.version       = Rails::Dom::Testing::VERSION
  spec.authors       = ["Rafael Mendonça França", "Kasper Timm Hansen"]
  spec.email         = ["rafaelmfranca@gmail.com", "kaspth@gmail.com"]
  spec.description   = %q{ Dom and Selector assertions for Rails applications }
  spec.summary       = %q{ This gem can compare doms and assert certain elements exists in doms using Nokogiri. }
  spec.homepage      = "https://github.com/kaspth/rails-dom-testing"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.test_files    = Dir["test/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6.0"
  spec.add_dependency "activesupport",  ">= 4.2.0", "< 5.0"
  spec.add_dependency "rails-deprecated_sanitizer", '>= 1.0.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
