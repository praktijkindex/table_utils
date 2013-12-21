require "csv"

class CSV
  class Stream
    def initialize path, opts = {}
      @path,@opts = path,opts
    end

    def count
      `wc -l #{@path}`.to_i - 1
    end

    def each &block
      CSV.foreach @path, @opts do |row|
        yield row
      end
    end

  end

  def self.stream path, opts = {}, &block
    stream = Stream.new path, opts
    if block_given?
      stream.each &block
    else
      stream
    end
  end
end
