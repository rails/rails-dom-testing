module Rails
  module Dom
    module Testing
      module Assertions
        module DomAssertions
          NODE_PADDING = ' '.freeze

          # \Test two HTML strings for equivalency (e.g., equal even when attributes are in another order)
          #
          #   # assert that the referenced method generates the appropriate HTML string
          #   assert_dom_equal '<a href="http://www.example.com">Apples</a>', link_to("Apples", "http://www.example.com")
          def assert_dom_equal(expected, actual, message = nil)
            expected_dom, actual_dom = fragment(expected), fragment(actual)
            message ||= "Expected: #{expected}\nActual: #{actual}"
            assert compare_doms(expected_dom, actual_dom), message
          end

          # The negated form of +assert_dom_equal+.
          #
          #   # assert that the referenced method does not generate the specified HTML string
          #   assert_dom_not_equal '<a href="http://www.example.com">Apples</a>', link_to("Oranges", "http://www.example.com")
          def assert_dom_not_equal(expected, actual, message = nil)
            expected_dom, actual_dom = fragment(expected), fragment(actual)
            message ||= "Expected: #{expected}\nActual: #{actual}"
            assert_not compare_doms(expected_dom, actual_dom), message
          end

          protected

            def compare_doms(expected, actual)
              return false unless expected.children.size == actual.children.size

              expected.children.each_with_index do |child, i|
                return false unless equal_children?(child, actual.children[i])
              end

              true
            end

            def equal_children?(child, other_child)
              return false unless child.type == other_child.type

              if child.element?
                child.name == other_child.name &&
                    equal_attribute_nodes?(child.attribute_nodes, other_child.attribute_nodes) &&
                    compare_doms(child, other_child)
              else
                child.to_s == other_child.to_s
              end
            end

            def equal_attribute_nodes?(nodes, other_nodes)
              return false unless nodes.size == other_nodes.size

              nodes = nodes.sort_by(&:name)
              other_nodes = other_nodes.sort_by(&:name)

              nodes.each_with_index do |attr, i|
                return false unless equal_attribute?(attr, other_nodes[i])
              end

              true
            end

            def equal_attribute?(attr, other_attr)
              attr.name == other_attr.name && attr.value == other_attr.value
            end

          private

            def fragment(text)
              Nokogiri::HTML::DocumentFragment.parse(text).tap do |fragment|
                pad_tags(fragment.children)
                condense_whitespace(fragment.children)
              end
            end

            def pad_tags(node)
              return node.each { |n| pad_tags(n) } if node.is_a?(Nokogiri::XML::NodeSet)
              return unless node.element?

              if (previous = node.previous_sibling) && previous.text?
                previous.content += NODE_PADDING
              else
                node.add_previous_sibling(NODE_PADDING)
              end

              if (first = node.children.first) && first.text?
                first.content = NODE_PADDING + first.content
              else
                node.prepend_child(NODE_PADDING)
              end

              if (last = node.children.last) && last.text?
                last.content = NODE_PADDING + last.content
              else
                node.add_child(NODE_PADDING)
              end

              if (after = node.next_sibling) && after.text?
                after.content += NODE_PADDING
              else
                node.add_next_sibling(NODE_PADDING)
              end

              pad_tags(node.children)
            end

            def condense_whitespace(node)
              if node.is_a?(Nokogiri::XML::NodeSet)
                node.each { |element| condense_whitespace(element) }
              elsif node.element?
                condense_whitespace(node.children)
              else
                text = node.text
                text.gsub!(/\s+/, ' ')
                text.strip!

                text.empty? ? node.remove : node.content = text
              end
            end
        end
      end
    end
  end
end
