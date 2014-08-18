require 'test_helper'
require 'rails/dom/testing/assertions/tag_assertions'

HTML_TEST_OUTPUT = <<HTML
<html>
  <body>
    <a href="/"><img src="/images/button.png" /></a>
    <div id="foo">
      <ul>
        <li class="item">hello</li>
        <li class="item">goodbye</li>
      </ul>
    </div>
    <div id="bar">
      <form action="/somewhere">
        Name: <input type="text" name="person[name]" id="person_name" />
      </form>
    </div>
  </body>
</html>
HTML

class AssertTagTest < ActiveSupport::TestCase
  include Rails::Dom::Testing::Assertions::TagAssertions

  class FakeResponse
    attr_accessor :content_type, :body

    def initialize(content_type, body)
      @content_type, @body = content_type, body
    end
  end

  setup do
    @response = FakeResponse.new 'html', HTML_TEST_OUTPUT
  end

  def test_assert_tag_tag
    # there is a 'form' tag
    assert_tag tag: 'form'
    # there is not an 'hr' tag
    assert_no_tag tag: 'hr'
  end

  def test_assert_tag_attributes
    # there is a tag with an 'id' of 'bar'
    assert_tag attributes: { id: "bar" }
    # there is no tag with a 'name' of 'baz'
    assert_no_tag attributes: { name: "baz" }
  end

  def test_assert_tag_parent
    # there is a tag with a parent 'form' tag
    assert_tag parent: { tag: "form" }
    # there is no tag with a parent of 'input'
    assert_no_tag parent: { tag: "input" }
  end

  def test_assert_tag_child
    # there is a tag with a child 'input' tag
    assert_tag child: { tag: "input" }
    # there is no tag with a child 'strong' tag
    assert_no_tag child: { tag: "strong" }
  end

  def test_assert_tag_ancestor
    # there is a 'li' tag with an ancestor having an id of 'foo'
    assert_tag ancestor: { attributes: { id: "foo" } }, tag: "li"
    # there is no tag of any kind with an ancestor having an href matching 'foo'
    assert_no_tag ancestor: { attributes: { href: /foo/ } }
  end

  def test_assert_tag_descendant
    # there is a tag with a descendant 'li' tag
    assert_tag descendant: { tag: "li" }
    # there is no tag with a descendant 'html' tag
    assert_no_tag descendant: { tag: "html" }
  end

  def test_assert_tag_sibling
    # there is a tag with a sibling of class 'item'
    assert_tag sibling: { attributes: { class: "item" } }
    # there is no tag with a sibling 'ul' tag
    assert_no_tag sibling: { tag: "ul" }
  end

  def test_assert_tag_after
    # there is a tag following a sibling 'div' tag
    assert_tag after: { tag: "div" }
    # there is no tag following a sibling tag with id 'bar'
    assert_no_tag after: { attributes: { id: "bar" } }
  end

  def test_assert_tag_before
    # there is a tag preceding a tag with id 'bar'
    assert_tag before: { attributes: { id: "bar" } }
    # there is no tag preceding a 'form' tag
    assert_no_tag before: { tag: "form" }
  end

  def test_assert_tag_children_count
    # there is a tag with 2 children
    assert_tag children: { count: 2 }
    # in particular, there is a <ul> tag with two children (a nameless pair of <li>s)
    assert_tag tag: 'ul', children: { count: 2 }
    # there is no tag with 4 children
    assert_no_tag children: { count: 4 }
  end

  def test_assert_tag_children_less_than
    # there is a tag with less than 5 children
    assert_tag children: { less_than: 5 }
    # there is no 'ul' tag with less than 2 children
    assert_no_tag children: { less_than: 2 }, tag: "ul"
  end

  def test_assert_tag_children_greater_than
    # there is a 'body' tag with more than 1 children
    assert_tag children: { greater_than: 1 }, tag: "body"
    # there is no tag with more than 10 children
    assert_no_tag children: { greater_than: 10 }
  end

  def test_assert_tag_children_only
    # there is a tag containing only one child with an id of 'foo'
    assert_tag children: { count: 1,
                              only: { attributes: { id: "foo" } } }
    # there is no tag containing only one 'li' child
    assert_no_tag children: { count: 1, only: { tag: "li" } }
  end

  def test_assert_tag_content
    # the output contains the string "Name"
    assert_tag content: /Name/
    # the output does not contain the string "test"
    assert_no_tag content: /test/
  end

  def test_assert_tag_multiple
    # there is a 'div', id='bar', with an immediate child whose 'action'
    # attribute matches the regexp /somewhere/.
    assert_tag tag: "div", attributes: { id: "bar" },
               child: { attributes: { action: /somewhere/ } }

    # there is no 'div', id='foo', with a 'ul' child with more than
    # 2 "li" children.
    assert_no_tag tag: "div", attributes: { id: "foo" },
                  child: { tag: "ul",
                    children: { greater_than: 2, only: { tag: "li" } } }
  end

  def test_assert_tag_children_without_content
    # there is a form tag with an 'input' child which is a self closing tag
    assert_tag tag: "form",
      children: { count: 1,
        only: { tag: "input" } }

    # the body tag has an 'a' child which in turn has an 'img' child
    assert_tag tag: "body",
      children: { count: 1,
        only: { tag: "a",
          children: { count: 1,
            only: { tag: "img" } } } }
  end

  def test_assert_tag_attribute_matching
    @response.body = '<input type="text" name="my_name">'
    assert_tag tag: 'input',
                 attributes: { name: /my/, type: 'text' }
    assert_no_tag tag: 'input',
                 attributes: { name: 'my', type: 'text' }
    assert_no_tag tag: 'input',
                 attributes: { name: /^my$/, type: 'text' }
  end

  def test_assert_tag_content_matching
    @response.body = "<p>hello world</p>"
    assert_tag tag: "p", content: "hello world"
    assert_tag tag: "p", content: /hello/
    assert_no_tag tag: "p", content: "hello"
  end
end