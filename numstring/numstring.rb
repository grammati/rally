# numstring.rb

#require 'pry'

# Adds methods to the built-in Numeric class:
#  to_nl_string: returns a natural-language representation of the
#                number. eg: 23.45 => "twenty-tree point four-five"
#  to_currency_string: returns a natural-language representation of
#                      the number as dollars and cents.

module NumberFormat

  private

  NumberNames = {}

  NumberNames['en'] = {

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

  }

  def decompose(n, lang='en')
    # Decompose a number into an array of pairs of numbers and names
    # eg: 923000357 => [[923, "million"], [0, "thousand"], [3,
    # "hundred"], [57, ""]]
    n = n.to_i
    steps = NumberNames[lang][:steps]
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

  def format_currency(n, lang='en')
    fmt = NumberNames[lang]
    
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

    result += format_number(dollars) + ' ' + pluralize('dollar', dollars) if include_dollars
    result += fmt[:and] if (include_dollars && include_cents)
    result += format_number(cents) + ' ' + pluralize('cent', cents) if include_cents

    result
  end

  def format_number(n, lang='en')
    n = n.to_i
    fmt = NumberNames[lang]

    # Negatives:
    return fmt[:negative] + format_number(-n) if n < 0

    # Special cases:
    s = fmt[:special][n]
    return s unless s.nil?

    # Numbers up to 100
    if n < 100
      return fmt[:special][n/10*10] + '-' + fmt[:special][n % 10]
    end

    # All other cases
    result = decompose(n).map {|num, name|
      format_number(num) + " " + name unless num.zero?
    }.reject(&:nil?).join(' ')
    rem = n % 100
    result += ' ' + format_number(rem) unless rem.zero?
    result
  end
  
end

class Numeric

  include NumberFormat

  def to_nl_string(lang = 'en')
    # Convert to natural language string
    "eleventy five"
  end

  def to_currency_string(lang = 'en', units=['dollar', 'cent'])
    # Convert to a natural language string representing a dollar
    # amout.
    # Note: Numbers are rounded to the nearest cent.
    format_currency(self)
  end
end
