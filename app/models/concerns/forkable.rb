# Allows long running methods to be forked easily
module Forkable
  extend ActiveSupport::Concern

  def fork_process(method)
    if Rails.env.test?
      send method
    else
      create_fork method
    end
  end

  private

  def create_fork(method)
    pid = Process.fork
    if pid.nil?
      send method
      Kernel.exit!
    else
      Process.detach pid
    end
  end
end
