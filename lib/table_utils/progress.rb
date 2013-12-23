require "ruby-progressbar"

module TableUtils
  module Progress
    DefaultOptions = {
      format: "%a |%b %c/%C =>%i| %E",
      throttle_rate: 0.1,
    }

    def self.bar options = {}
      bar = ProgressBar.create DefaultOptions.merge options
      bar.format("%a: |%i| %c") if bar.total == nil
      if block_given?
        begin
          yield bar
        ensure
          if bar.total
            bar.finish unless bar.finished?
          end
        end
      else
        bar
      end
    end

    def self.over enum, options = {}
      options = options.dup

      unless options.include? :total
        options[:total] = enum.count
      end

      Progress.bar options do |bar|
        enum.each do |i|
          bar.increment
          yield i, bar
        end
      end
    end

  end
end

require "csv"
class CSV
  def count
    oldpos = tell if respond_to?(:tell)
    super
  ensure
    seek oldpos if respond_to?(:seek)
  end
end
