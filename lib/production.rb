module Lindenmayer
  class InvalidProductionError < StandardError
  end

  # Base Production
  # Replaces a single character with a string, or applies stochastic weighting
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
end