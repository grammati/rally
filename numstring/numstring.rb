# numstring.rb
# 
# Defines the class NumberFormatter, which is responsible for
# converting numbers into string representations in a particular
# language.
# 
# The only language supported out-of-the-box is English.
# The only method currently implemented is format_currency, which
# currently uses dollars and cents as the units.
# 
# Example:
# formatter = NumberFormatter.for_lang('en')
# formatter.format_currency(23.4) => "twenty-three dollars and forty
# cents". 

# Also adds methods to the built-in Numeric class:
#  to_currency_string: returns a natural-language representation of
#                      the number as dollars and cents.
#  eg: 23.4.to_currency_string => "twenty-three dollars and forty
#  cents".

# TODO
# * validate that other languages can be plugged in, and it works
# * don't hard-code "dollars" and "cents"
# * language-specific pluralization
# * support hooks for languages that do not fit as a word-for-word
# tranlation from English (eg: 98 in French = "quatre-vignt dix-huit"
# - literally "eighty-eighteen")

class NumberFormatter

  public
  
  private_class_method :new

  def self.register_formatter(lang, format)
    @instances ||= {}
    @instances[lang] = new(format)
  end

  def self.for_lang(lang)
    @instances ||= {}
    @instances[lang] or raise "No formatter for language #{lang}"
  end


  attr_reader :fmt

  def initialize(format)
    @fmt = format
  end

  def format_currency(n)
    # Deal with negatives here, to avoid things like "minus one dollar
    # and minus three cents"
    result = n < 0 ? fmt[:negative] : ''
    n = n.abs

    cents = ((n % 1.0) * 100).round.to_i
    dollars = n.floor.to_i

    # Determine whether to include the dollars part and/or the cents
    # part. Make sure to return "zero dollars", not "zero cents" for 0.
    include_dollars = n.zero? || !dollars.zero?
    include_cents = !cents.zero?

    result += format_int(dollars) + ' ' + pluralize('dollar', dollars) if include_dollars
    result += fmt[:and] if (include_dollars && include_cents)
    result += format_int(cents) + ' ' + pluralize('cent', cents) if include_cents

    result
  end


  private

  def format_int(n)
    n = n.to_i

    # Negatives:
    return fmt[:negative] + format_int(-n) if n < 0

    # Special cases:
    s = fmt[:special][n]
    return s unless s.nil?

    # Numbers up to 100
    if n < 100
      return fmt[:special][n/10*10] + '-' + fmt[:special][n % 10]
    end

    # All other cases
    result = decompose(n).map {|num, name|
      format_int(num) + " " + name unless num.zero?
    }.reject(&:nil?).join(' ')
    rem = n % 100
    result += ' ' + format_int(rem) unless rem.zero?
    result
  end
  
  def decompose(n, lang='en')
    # Decompose a number into an array of pairs of numbers and names
    # eg: 923000357 => [[923, "million"], [0, "thousand"], [3,
    # "hundred"], [57, ""]]
    n = n.to_i
    steps = fmt[:steps]
    steps.each {|step,name|
      if n >= step
        return [[n / step, name]] + decompose(n % step)
      end
    }
    []
  end

  def pluralize(unit, n)
    # TODO - make this localizable
    return unit + (n.abs == 1 ? '' : 's')
  end

end



# Register the English formatter by default
NumberFormatter.register_formatter('en', {

    :negative => 'minus ',
    
    :and => ' and ',
    
    :special => {
      0 => "zero",
      1 => "one",
      2 => "two",
      3 => "three",
      4 => "four",
      5 => "five",
      6 => "six",
      7 => "seven",
      8 => "eight",
      9 => "nine",
      10 => "ten",
      11 => "eleven",
      12 => "twelve",
      13 => "thirteen",
      14 => "fourteen",
      15 => "fifteen",
      16 => "sixteen",
      17 => "seventeen",
      18 => "eighteen",
      19 => "nineteen",
      20 => "twenty",
      30 => "thirty",
      40 => "forty",
      50 => "fifty",
      60 => "sixty",
      70 => "seventy",
      80 => "eighty",
      90 => "ninety",
    },

    :steps => [
      # Do not use quadrillion, quintillion, etc. - just use "one
      # thousand trillion", "ten trillion trillion" etc. ad infinitum
      [1e12.to_i, "trillion"],
      [1e9.to_i, "billion"],
      [1e6.to_i, "million"],
      [1e3.to_i, "thousand"],
      [1e2.to_i, "hundred"],
    ]

  })


######################
# Monkey-patch Numeric

class Numeric

  def to_nl_string(lang = 'en')
    # Convert to natural language string
    "eleventy five"
  end

  def to_currency_string(lang = 'en')
    # Convert to a natural language string representing a dollar
    # amout.
    # Note: Numbers are rounded to the nearest cent.
    NumberFormatter.for_lang(lang).format_currency(self)
  end
end
