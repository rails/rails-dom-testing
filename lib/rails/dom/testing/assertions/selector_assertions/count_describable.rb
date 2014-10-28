require 'active_support/concern'

module CountDescripable
  extend ActiveSupport::Concern

  private
    def count_description(min, max, count) #:nodoc:
      if min && max && (max != min)
        "between #{min} and #{max} elements"
      elsif min && max && max == min && count
        "exactly #{count} #{pluralize(min)}"
      elsif min && !(min == 1 && max == 1)
        "at least #{min} #{pluralize(min)}"
      elsif max
        "at most #{max} #{pluralize(max)}"
      end
    end

    def pluralize(quantity)
      quantity == 1 ? 'element' : 'elements'
    end
end
