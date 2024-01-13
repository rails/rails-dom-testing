# rails-dom-testing changelog

## next / unreleased

### Added

* Introduce test helpers `assert_not_dom`, `assert_not_select`, and the "refute" equivalents. #113 @joshuay03


### Improved

* `assert_select` now raises an error when given an invalid Range or invalid combination of `:minimum` and `:maximum`. #115 @joshuay03
* `assert_select` now raises an error when given a block with a 0 element assertion. #116 @joshuay03


### New Contributors

* @joshuay03 made their first three contributions in this release.


## v2.2.0 / 2023-08-03

### What's Changed

* Allow user to choose the HTML parser used by @flavorjones in https://github.com/rails/rails-dom-testing/pull/109
* Fix string substitution regression by @nicoco007 in https://github.com/rails/rails-dom-testing/pull/110

### New Contributors

* @nicoco007 made their first contribution in https://github.com/rails/rails-dom-testing/pull/110
