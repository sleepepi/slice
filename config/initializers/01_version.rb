module Slice
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 30
    TINY = 0
    BUILD = nil # nil, 'pre', 'beta1', 'beta2', 'rc', 'rc2'

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
