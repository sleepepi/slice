# frozen_string_literal: true

json.version do
  json.string Slice::VERSION::STRING
  json.major Slice::VERSION::MAJOR
  json.minor Slice::VERSION::MINOR
  json.tiny Slice::VERSION::TINY
  json.build Slice::VERSION::BUILD
end
