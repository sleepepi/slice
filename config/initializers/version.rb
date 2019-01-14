# frozen_string_literal: true

module Slice
  module VERSION #:nodoc:
    MAJOR = 69
    MINOR = 0
    TINY = 0
    BUILD = "beta2" # "pre", "beta1", "beta2", "rc", "rc2", nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join(".").freeze
  end
end
