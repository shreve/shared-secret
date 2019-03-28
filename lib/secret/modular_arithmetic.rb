module Secret
  # Modular Arithmetic helpers
  # Used to ensure safe inversion of numbers in mod space
  module ModularArithmetic
    class << self
      # Compute the Bezout coefficients of a and b
      def extended_gcd(a, b)
        # trivial case first: gcd(a, 0) == 1*a + 0*0
        return [1, 0] if b.zero?

        # a = q * b + r
        q, r = a.divmod b

        # gcd(b, r) = s * b + t * r
        s, t = extended_gcd(b, r)

        # s * b + t * r == s * b + t * (a - q*b)
        [t, s - q * t]
      end

      # Returns the inverse of `num` modulo `mod`.
      def invert(num, mod)
        a, = extended_gcd(num, mod)
        a % mod
      end
    end
  end
end
