# frozen_string_literal: true

module Slice
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 33
    TINY = 0
    BUILD = 'pre'.freeze # nil, 'pre', 'beta1', 'beta2', 'rc', 'rc2'

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.').freeze
  end
end
