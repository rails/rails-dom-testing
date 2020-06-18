require 'test_helper'
require 'rails/dom/testing/assertions/dom_assertions'

class DomAssertionsTest < ActiveSupport::TestCase
  Assertion = Minitest::Assertion

  include Rails::Dom::Testing::Assertions::DomAssertions

  def test_responds_to_assert_dom_equal
    assert respond_to?(:assert_dom_equal)
  end

  def test_dom_equal
    html = '<a></a>'
    assert_dom_equal(html, html.dup)
  end

  def test_equal_doms_with_different_order_attributes
    attributes = %{<a b="hello" c="hello"></a>}
    reverse_attributes = %{<a c="hello" b="hello"></a>}
    assert_dom_equal(attributes, reverse_attributes)
  end

  def test_dom_not_equal
    assert_dom_not_equal('<a></a>', '<b></b>')
  end

  def test_unequal_doms_attributes_with_different_order_and_values
    attributes = %{<a b="hello" c="hello"></a>}
    reverse_attributes = %{<a c="hello" b="goodbye"></a>}
    assert_dom_not_equal(attributes, reverse_attributes)
  end

  def test_custom_message_is_used_in_failures
    message = "This is my message."

    e = assert_raises(Assertion) do
      assert_dom_equal('<a></a>', '<b></b>', message)
    end

    assert_equal e.message, message
  end

  def test_unequal_dom_attributes_in_children
    assert_dom_not_equal(
      %{<a><b c="1" /></a>},
      %{<a><b c="2" /></a>}
    )
  end

  def test_dom_equal_with_whitespace_strict
    canonical = %{<a><b>hello</b> world</a>}
    assert_dom_not_equal(canonical, %{<a>\n<b>hello\n </b> world</a>}, strict: true)
    assert_dom_not_equal(canonical, %{<a> \n <b>\n hello</b> world</a>}, strict: true)
    assert_dom_not_equal(canonical, %{<a>\n\t<b>hello</b> world</a>}, strict: true)
    assert_dom_equal(canonical, %{<a><b>hello</b> world</a>}, strict: true)
  end

  def test_dom_equal_with_whitespace
    canonical = %{<a><b>hello</b> world</a>}
    assert_dom_equal(canonical, %{<a>\n<b>hello\n </b> world</a>})
    assert_dom_equal(canonical, %{<a>\n<b>hello </b>\nworld</a>})
    assert_dom_equal(canonical, %{<a> \n <b>\n hello</b> world</a>})
    assert_dom_equal(canonical, %{<a> \n <b> hello </b>world</a>})
    assert_dom_equal(canonical, %{<a> \n <b>hello </b>world\n</a>\n})
    assert_dom_equal(canonical, %{<a>\n\t<b>hello</b> world</a>})
    assert_dom_equal(canonical, %{<a>\n\t<b>hello </b>\n\tworld</a>})
  end

  def test_dom_equal_with_attribute_whitespace
    canonical = %(<div data-wow="Don't strip this">)
    assert_dom_equal(canonical, %(<div data-wow="Don't strip this">))
    assert_dom_not_equal(canonical, %(<div data-wow="Don't  strip this">))
  end

  def test_dom_equal_with_indentation
    canonical = %{<a>hello <b>cruel</b> world</a>}
    assert_dom_equal(canonical, <<-HTML)
<a>
  hello
  <b>cruel</b>
  world
</a>
    HTML

    assert_dom_equal(canonical, <<-HTML)
<a>
hello
<b>cruel</b>
world
</a>
    HTML

    assert_dom_equal(canonical, <<-HTML)
<a>hello
  <b>
    cruel
  </b>
  world</a>
    HTML
  end

  def test_dom_equal_with_surrounding_whitespace
    canonical = %{<p>Lorem ipsum dolor</p><p>sit amet, consectetur adipiscing elit</p>}
    assert_dom_equal(canonical, <<-HTML)
<p>
  Lorem
  ipsum
  dolor
</p>

<p>
  sit amet,
  consectetur
  adipiscing elit
</p>
    HTML
  end

  def test_dom_not_equal_with_interior_whitespace
    with_space    = %{<a><b>hello world</b></a>}
    without_space = %{<a><b>helloworld</b></a>}
    assert_dom_not_equal(with_space, without_space)
  end
end
