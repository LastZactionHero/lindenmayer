require 'pry'
require 'ostruct'

module Lindenmayer

  # Basic Production
  class Production
    attr_reader :transform

    # transform - (string) Replacement if matching
    def initialize(transform)
      @transform = transform
    end
  end

  # Context-Sensitive Production, checks if value matches in context
  # Handles left-only, right-only, and left-right context
  class ContextSensitiveProduction
    attr_reader :key

    # key - (string) Full key, e.g. "AB<C>DE"
    # transform - (string) Replacement if matching
    def initialize(key, transform)
      @lookahead = key.include?('>') ? key.rpartition('>').last : nil
      @lookbehind = key.include?('<') ? key.partition('<').first : nil
      @key = key.rpartition('<').last.partition('>').first
      @transform = transform
    end

    def transform(idx, context)
      if (@lookbehind.nil? ||
          includes_full_context?(context[0, idx], @lookbehind)) &&
         (@lookahead.nil? ||
          includes_full_context?(context[(idx + 1)..-1], @lookahead))
        @transform
      else
        @key
      end
    end

    private

    def includes_full_context?(context, required_context)
      required_context = required_context.dup.split('')

      context.split('').each do |char|
        required_context.shift if required_context[0] == char
      end

      required_context.empty?
    end
  end

  # Lindenmayer System
  class LSystem
    def initialize(axiom, productions)
      @axiom = axiom

      @cs_productions = {}
      cs_keys = productions.keys.select { |k| k.match(/[<>]/) }
      cs_keys.each do |key|
        value = productions.delete(key)
        cs_prod = ContextSensitiveProduction.new(key, value)
        @cs_productions[cs_prod.key] = cs_prod
      end

      @productions = productions.map { |key, transform| [key, Production.new(transform)] }.to_h
    end

    def iterate(count = 1)
      count.times do
        @axiom = @axiom.split('').each_with_index.map do |c, c_idx|
          if @productions[c]
            @productions[c].transform
          elsif @cs_productions[c]
            @cs_productions[c].transform(c_idx, @axiom)
          else
            c
          end
        end.join
      end
      @axiom
    end
  end
end
