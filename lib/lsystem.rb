require 'pry'

module Lindenmayer
  # Lindenmayer System
  class LSystem
    def initialize(axiom, productions)
      @axiom = axiom
      @productions = productions
    end

    def iterate(count = 1)
      count.times do
        @axiom = @axiom.split('').map do |c|
          @productions[c] || c
        end.join
      end
      @axiom
    end
  end
end
