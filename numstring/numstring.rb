# numstring.rb

# Adds methods to the built-in Numeric class:
#  to_nl_string: returns a natural-language representation of the
#                number. eg: 23.45 => "twenty-tree point four-five"
#  to_currency_string: returns a natural-language representation of
#                      the number as dollars and cents.


class Numeric

  def to_nl_string(lang = 'en')
    # Convert to natural language string
    "eleventy five"
  end

  def to_currency_string(lang = 'en', units=['dollar', 'cent'])
    # Convert to a natural language string representing a dollar
    # amout.
    # Note: Numbers are rounded to the nearest cent.
    "fiddy cent"
  end

end
