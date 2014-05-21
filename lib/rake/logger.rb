require 'logger'

module Rake::DSL
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new STDOUT
    end
  end

  def logger
    Rake::DSL.logger
  end

  def logger= new_logger
    Rake::DSL.logger= new_logger
  end
end
