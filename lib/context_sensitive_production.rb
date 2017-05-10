module Lindenmayer

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
end