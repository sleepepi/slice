# frozen_string_literal: true

# See: http://chriseppstein.github.io/blog/2010/02/08/haml-sucks-for-content/

# Performance
# The :ugly option was actually added to make haml faster. With it on, Haml is
# approximately the same speed as ERB. With it off, Haml is 2.8 times slower
# than ERB. NOTE: the production environment default is to turn :ugly on.
# But with tools like firebug, I just don't see the point in having
# pretty-printed html even in development. So again, I recommend you just turn
# :ugly on and treat it is a debugging tool.

Haml::Template.options[:ugly] = true
