require_relative 'secret/modular_arithmetic'
require_relative 'secret/variable'
require_relative 'secret/bsencode'

require_relative 'core_ext/integer'
require_relative 'core_ext/array'

module Secret
  # Generated with `openssl prime -generate -bits 1024`
  P = '1676878452444789559631549507476314355703778109943722423704987464602369' \
      '7880525014884973564538649304177233796426699071235910091234268808528829' \
      '5907801743377717524540368888821902191299103758458615804753988862056702' \
      '0311135845124784589058280563989413093745726942023732592900733383065856' \
      '54173537238799417265869847849'.to_i.freeze

  class << self
    def create(secret, shares:, required:)
      raise ArgumentError, "Shares must be less than #{P}" if shares >= P
      raise ArgumentError, 'Required must be at most shares' if required > shares
      raise ArgumentError, 'Required must be greater than 1' if required <= 1

      coefficients = Array.new(required).map { rand(99) }
      coefficients[0] = BSEncode.encode(secret)

      Array.new(shares).map.with_index do |_, i|
        "#{i + 1}-#{f(i + 1, coefficients)}"
      end
    end

    def restore(codes)
      codes = codes.map { |s| s.split('-').map(&:to_i) }
      us = codes.map(&:first)
      vs = codes.map { |a| a[1] }
      denoms = us.map.with_index { |_, i| safemod li_denom(us, i) }
      numers = us.map.with_index { |_, i| li_num(us, i) * denoms[i] }
      terms = numers.map.with_index { |term, i| term * vs[i] }
      BSEncode.decode((terms.flatten.combine_like_terms % P).last)
    end

    private

    def li_denom(us, i)
      us = us.rotate(i)
      u1 = us[0]
      us = us[1..-1]
      us.map { |u| u1 - u }.reduce(:*)
    end

    def li_num(us, i)
      us = us.rotate(i)
      us = us[1..-1]
      us.map { |u| [x, -1*u] }.reduce(:*)
    end

    def x
      Variable.new
    end

    def f(unum, coeffs)
      coeffs.map.with_index do |coeff, i|
        coeff * (unum**i)
      end.reduce(:+) % P
    end

    def safemod(int)
      ModularArithmetic.invert(int, P)
    end
  end
end
