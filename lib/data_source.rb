require "active_record"
require "activerecord-import"
require "table_utils/progress"

class DataSource
  attr_reader :table_name, :input_path

  def initialize table_name, input_path, csv_opts = {}, &block
    @table_name, @input_path = table_name, input_path
    @csv_opts = csv_opts ? csv_opts.dup : {}
    ImportDSL.new self, &block
  end

  def import
    batch = []
    TableUtils::Progress.over csv do |row, bar|
      transform_record row
      common_columns = model.column_names & row.headers
      batch << common_columns.map{ |c| row[c] }
      if batch.count >= 1000 || bar.finished?
        model.import common_columns, batch, validate: false
        batch = []
      end
    end
  end

  def define_table
    raise "No table definition supplied for #{@table_name}"
  end

  def transform_record ignored_record

  end

  def table_exists?
    conn.table_exists? table_name
  end

  def drop_table
    conn.drop_table table_name
  end

  private

  class ImportDSL
    attr_reader :source

    def initialize source, &block
      @source = source
      instance_eval &block
    end

    [:define_table, :transform_record].each do |hook|
      define_method hook do |&block|
        source.define_singleton_method hook, block
      end
    end
  end

  attr_accessor :csv_opts

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def model
    conn.create_table table_name do |t|
      define_table t
    end unless table_exists?
    _table_name = table_name
    @model ||= Class.new(ActiveRecord::Base) { self.table_name = _table_name }
  end

  def csv
    @csv ||= begin
               csv_opts[:headers] ||= model.column_names - %w(id created_at updated_at)
               csv_opts[:return_headers] = true
               CSV.open(input_path, csv_opts).tap do |csv|
                 csv.shift
                 csv.shift if Array === csv_opts[:headers]
               end
             end
  end
end