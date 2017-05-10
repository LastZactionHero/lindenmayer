require 'pry'
require 'ostruct'

module Lindenmayer
  class InvalidProductionError < StandardError
  end

  # Basic Production
  # Replaces a single character with a string
  class Production
    attr_reader :transform


    # transform - (string) Replacement if matching
    def initialize(transform, options = {})
      @transform = transform
      post_init(options)
    end

    def transform(idx, context)
      apply_transform
    end

    protected

    def post_init(options)
      @random = options[:random] || Random.new
      validate_stochastic if stochastic?
    end

    def apply_transform
      if stochastic?
        apply_stochastic_transform
      else
        @transform
      end
    end

    def apply_stochastic_transform
      random_value = @random.rand

      transform_idx = nil
      summed_stochastic_weights.each_with_index do |weight, weight_idx|
        transform_idx = weight_idx and break if random_value <= weight
      end

      @transform[:successors][transform_idx][:successor]
    end

    def summed_stochastic_weights
      @summed_weights ||= stochastic_weights.each_with_index.map { |weight, idx| stochastic_weights[0..idx].reduce(:+) }
    end

    def stochastic_weights
      @stochastic_weights ||= @transform[:successors].map { |s| s[:weight] }
    end

    def stochastic?
      return false if @transform.is_a?(String)
      if @transform.is_a?(Hash) && @transform[:successors].any?
        true
      else
        # Whatever you are, we don't suppor it
        raise InvalidProductionError
      end
    end

    def validate_stochastic
      raise InvalidProductionError unless summed_stochastic_weights.last == 1
    end

  end

  # Context-Sensitive Production, checks if value matches in context
  # Handles left-only, right-only, and left-right context
  class ContextSensitiveProduction < Production
    attr_reader :key

    # key - (string) Full key, e.g. "AB<C>DE"
    # transform - (string) Replacement if matching
    def initialize(key, transform, options = {})
      @lookahead = key.include?('>') ? key.rpartition('>').last : nil
      @lookbehind = key.include?('<') ? key.partition('<').first : nil
      @key = key.rpartition('<').last.partition('>').first
      @transform = transform
      post_init(options)
    end

    def transform(idx, context)
      if (@lookbehind.nil? ||
          includes_full_context?(context[0, idx], @lookbehind)) &&
         (@lookahead.nil? ||
          includes_full_context?(context[(idx + 1)..-1], @lookahead))
        apply_transform
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
