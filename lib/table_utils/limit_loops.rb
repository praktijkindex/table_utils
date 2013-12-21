module TableUtils
  class LimitLoops
    attr_reader :total

    def initialize max_count
      @total = @left_count = max_count
    end

    def limit
      catch(self) { yield self }
    end

    def check!
      throw self if @left_count and (@left_count -= 1) <= 0
    end

    def self.to max_count, &block
      LimitLoops.new(max_count).limit &block
    end
  end
end
