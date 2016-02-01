# frozen_string_literal: true

# Allows long running methods to be forked easily
module Forkable
  extend ActiveSupport::Concern

  def fork_process(method, *args)
    if Rails.env.test?
      send method, *args
    else
      create_fork method, *args
    end
  end

  private

  def create_fork(method, *args)
    pid = Process.fork
    if pid.nil?
      send method, *args
      Kernel.exit!
    else
      Process.detach pid
    end
  end
end
