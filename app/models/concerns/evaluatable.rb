# frozen_string_literal: true

# Allows evaluation of JavaScript expressions
module Evaluatable
  extend ActiveSupport::Concern

  # Since showing and hiding variables is done client side by JavaScript,
  # the corresponding action should also apply when printing out the variable
  # in a PDF document. Since PDF documents don't run JavaScript, the solution
  # presented uses a JavaScript evaluator to evaluate the branching logic.

  def exec_js_context
    @exec_js_context ||= begin
      ExecJS.compile(js_index_of + js_intersection + js_overlap)
    end
  end

  private

  # Compiled CoffeeScript from designs.js.coffee
  def js_index_of
    "var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.l"\
    "ength; i < l; i++) { if (i in this && this[i] === item) return i; } retur"\
    "n -1; };"
  end

  def js_intersection
    "this.intersection = function(a, b) { var value, _i, _len, _ref, _results;"\
    " if (a.length > b.length) { _ref = [b, a], a = _ref[0], b = _ref[1]; } _r"\
    "esults = []; for (_i = 0, _len = a.length; _i < _len; _i++) { value = a[_"\
    "i]; if (__indexOf.call(b, value) >= 0) { _results.push(value); } } return"\
    " _results; };"
  end

  def js_overlap
    "this.overlap = function(a, b, c) { "\
    "if (c == null) { c = 1; } "\
    "a = (a || []).map(String); "\
    "b = (b || []).map(String); "\
    "return intersection(a, b).length >= c; "\
    "};"
  end
end
