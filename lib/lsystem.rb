require 'ostruct'
require 'production'
require 'context_sensitive_production'

module Lindenmayer
  # Lindenmayer System
  class LSystem
    def initialize(axiom, productions, options = {})
      @axiom = axiom
      @random = options[:random]

      @productions = productions.map do |key, transform|
        k, production = if key.match(/[<>]/)
          cs_prod = ContextSensitiveProduction.new(key, transform, random: @random)
          [cs_prod.key, cs_prod]
        else
          [key, Production.new(transform, random: @random)]
        end
        [k, production]
      end.to_h
    end

    def iterate(count = 1)
      count.times do
        @axiom = @axiom.split('').each_with_index.map do |c, c_idx|
          if @productions[c]
            @productions[c].transform(c_idx, @axiom)
          else
            c
          end
        end.join
      end
      @axiom
    end
  end
end
