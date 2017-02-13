# frozen_string_literal: true

# Provides methods for computing array statistics.
class Statistics
  def self.array_mean(array)
    new(array).array_mean
  end

  def self.array_sample_variance(array)
    new(array).array_sample_variance
  end

  def self.array_standard_deviation(array)
    new(array).array_standard_deviation
  end

  def self.array_median(array)
    new(array).array_median
  end

  def self.array_max(array)
    new(array).array_max
  end

  def self.array_min(array)
    new(array).array_min
  end

  def self.array_count(array)
    new(array).array_count
  end

  attr_accessor :array

  def initialize(array)
    @array = array
  end

  def array_mean
    return nil if @array.empty?
    @array.inject(:+).to_f / @array.size
  end

  def array_sample_variance
    m = array_mean
    sum = @array.inject(0) { |acc, elem| acc + (elem - m)**2 }
    sum / (@array.length - 1).to_f
  end

  def array_standard_deviation
    return nil if @array.size < 2
    Math.sqrt(array_sample_variance)
  end

  def array_median
    return nil if @array.empty?
    @array = @array.sort
    len = @array.size
    if len.odd?
      @array[len / 2]
    else
      (@array[len / 2 - 1] + @array[len / 2]).to_f / 2
    end
  end

  def array_max
    @array.max
  end

  def array_min
    @array.min
  end

  def array_count
    @array.size if @array.present?
  end
end
