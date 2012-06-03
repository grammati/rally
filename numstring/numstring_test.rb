require './numstring'
require 'test/unit'

class NumstringTest < Test::Unit::TestCase

  def test_to_currency_string
    [
     # Simple cases:
     0, "zero dollars",
     1, "one dollar",           # special case - not pluralized
     2, "two dollars",
     9, "nine dollars",
     10, "ten dollars",

     # Teens are special in English
     11, "eleven dollars",
     12, "twelve dollars",
     13, "thirteen dollars",
     14, "fourteen dollars",
     15, "fifteen dollars",
     16, "sixteen dollars",
     17, "seventeen dollars",
     18, "eighteen dollars",
     19, "nineteen dollars",

     # The multiples of 10 (eg: twenty, thirty, etc) each have their
     # own special word in English, so check each at least once.
     20, "twenty dollars",
     30, "thirty dollars",
     42, "forty-two dollars",
     53, "fifty-three dollars",
     60.87, "sixty dollars and eighty-seven cents",
     77, "seventy-seven dollars",
     80, "eighty dollars",
     90, "ninety dollars",

     # Cents only
     0.01, "one cent",
     0.02, "two cents",
     0.99, "ninety-nine cents",
     
     # I have defined the method to discard fractional cents (currency
     # traders may cringe at this)
     0.144997, "fourteen cents",
     0.145001, "fifteen cents",

     # Negative numbers
     -1, "minus one dollar",
     -2, "minus two dollars",
     -0.01, "minus one cent",
     -17.45, "minus seventeen dollars and forty-five cents",

     # Some bigger numbers
     100.00, "one hundred dollars",
     100.02, "one hundred dollars and two cents",
     101, "one hundred one dollars",
     101.01, "one hundred one dollars and one cent",
     199.99, "one hundred ninety-nine dollars and ninety-nine cents",
     765.00, "seven hundred sixty-five dollars",

     # And some big, complex ones
     2523.04,  "two thousand five hundred twenty-three dollars and four cents",
     1000000, "one million dollars", # insert Dr. Evil joke here
     923002388.19, "nine hundred twenty-three million two thousand three hundred eighty-eight dollars and nineteen cents",
     1000000001, "one billion one dollars",
     1234567890, 'one billion two hundred thirty-four million five hundred sixty-seven thousand eight hundred ninety dollars',
     123456789000, 'one hundred twenty-three billion four hundred fifty-six million seven hundred eighty-nine thousand dollars',
     12345678900000, 'twelve trillion three hundred forty-five billion six hundred seventy-eight million nine hundred thousand dollars',
     1234567890000000, 'one thousand two hundred thirty-four trillion five hundred sixty-seven billion eight hundred ninety million dollars',
     123456789000000000, 'one hundred twenty-three thousand four hundred fifty-six trillion seven hundred eighty-nine billion dollars',
     10000000000000000000000000000001, 'ten million trillion trillion one dollars', # sounds a bit funny without "and" before the "one"... oh well
     
     
    ].each_slice(2) do |n,s|
      assert_equal(s, n.to_currency_string)
    end
  end
end
