module Rake::DSL
  attr_writer :logger

  def logger
    @logger ||= Logger.new STDOUT
  end
end
