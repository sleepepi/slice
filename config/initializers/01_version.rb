module Reading
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 3
    TINY = 1
    BUILD = nil # nil, "pre", "beta1", "beta2", "rc", "rc2"

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
