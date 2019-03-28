require_relative 'secret/modular_arithmetic'
require_relative 'secret/variable'
require_relative 'secret/bsencode'

require_relative 'core_ext/integer'
require_relative 'core_ext/array'

module Secret
  # Generated with `openssl prime -generate -bits 2048`
  P = '3161683644626285334401958404120077046519512952291704469591099093219524' \
      '1007559839874495277360103430136214536812362168226347164860201368712629' \
      '5069975205915256597309904835946788945099037277969447626290780094488257' \
      '9104402906119840841843765394997724859904807335007881214702662336835135' \
      '9839952460008509690878198504688652732016066791464141587342914651963968' \
      '3491441213707714530583783871477574253352808188833922960460852397199963' \
      '2370093658684142341428090583891369763645442796505178521625551428326146' \
      '7122003364072216412790232025994459550445996685831487219061912310847062' \
      '423212150724846817512934536229184227621771474656325777949'.to_i.freeze


  class << self
    def create(secret, shares:, required:)
      raise ArgumentError, "Shares must be less than #{P}" if shares >= P
      raise ArgumentError, 'Required must be at most shares' if required > shares
      raise ArgumentError, 'Required must be greater than 1' if required <= 1

      coefficients = Array.new(required).map { rand(P) }
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
