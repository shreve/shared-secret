require 'base64'

module Secret
  # Encode strings as integers in a reversible way
  module StringInt
    class << self
      def encode(string)
        base64 = Base64.strict_encode64(string)
        bytes = base64.bytes
        val = 0
        bytes.each.with_index do |byte, i|
          val |= (byte << (i * 8))
        end
        val
      end

      def decode(int)
        bytes = []
        while int > 0
          bytes << (int & 255)
          int >>= 8
        end
        string = bytes.pack('c*')
        Base64.strict_decode64(string)
      end
    end
  end
end
