#!/usr/bin/env ruby

(1..100).each do |i|
  fizz = (i % 3) == 0? 1 : 0
  buzz = (i % 5) == 0? 1 : 0
  index = (buzz << 1) | fizz
  output = [i, "Fizz", "Buzz", "FizzBuzz"]
  puts output[index]
end