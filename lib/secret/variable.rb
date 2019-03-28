module Secret
  class Variable
    attr_accessor :exponent, :coefficient
    def initialize(coeff = 1, exp = 1)
      self.coefficient = coeff
      self.exponent = exp
    end

    def *(other)
      if other.is_a?(Variable)
        Variable.new(coefficient * other.coefficient,
                     exponent + other.exponent)
      else
        Variable.new(coefficient * other, exponent)
      end
    end

    def +(other)
      return self if exponent != other.exponent
      Variable.new(coefficient + other.coefficient, exponent)
    end

    def %(other)
      Variable.new(coefficient % other, exponent)
    end

    def to_s
      o = 'x'
      o = "#{coefficient}#{o}" if coefficient != 1
      o = "#{o}^#{exponent}" if exponent != 1
      o
    end

    def inspect
      to_s
    end
  end
end
