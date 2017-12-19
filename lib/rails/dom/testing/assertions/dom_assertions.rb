module Rails
  module Dom
    module Testing
      module Assertions
        module DomAssertions
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
                squish_insignificant_whitespace(fragment)
              end
            end

            def squish_insignificant_whitespace(block_node)
              # Distill down the textual contents of `block_node` into "runs"
              # of text nodes that are bridged by regions of whitespace:
              text_nodes = block_node.children.flat_map { |node| flattened_text_nodes(node) }
              text_nodes.last.content += ' ' if text_nodes.any?
              runs = text_nodes.slice_when { |t1, t2| t1.text !~ /\s\z/ || t2.text !~ /\A\s/ }

              runs.each do |run|
                # Preserve whitespace at the start of each run:
                squish_or_remove(run.shift, strip_left: false)
                # Remove whitespace from boundaries within the run:
                run.each { |text_node| squish_or_remove(text_node, strip_left: true) }
              end
            end

            def squish_or_remove(text_node, strip_left:)
              text = text_node.text

              text.gsub!(/\s+/, ' ')
              text.lstrip! if strip_left
              text.empty? ? text_node.remove : text_node.content = text
            end

            def flattened_text_nodes(node)
              return [node] unless node.element?
              node.children.flat_map { |child| flattened_text_nodes(child) }
            end
        end
      end
    end
  end
end
