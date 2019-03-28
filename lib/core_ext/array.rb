# Install additions to main array class
module ArrayPlusPlus
  # Vector multiplication
  def *(other)
    if other.is_a?(Array)
      map do |el|
        other.map do |oel|
          el * oel
        end
      end.flatten.combine_like_terms
    elsif other.is_a?(Integer)
      map do |el|
        el * other
      end
    end
  end

  # Ensure all elements are in same modulus
  def %(other)
    map do |el|
      el % other
    end
  end

  def combine_like_terms
    terms = select { |el| el.is_a?(Secret::Variable) }
    terms = terms.group_by(&:exponent)
    terms.each_pair do |_, list|
      if list.length > 1
        list.each { |el| delete(el) }
        push(list.reduce(:+))
      end
    end

    terms = select { |el| el.is_a?(Integer) }
    delete_if { |el| el.is_a?(Integer) }
    push(terms.reduce(:+))
    self
  end
end

Array.class_eval { prepend ArrayPlusPlus }
