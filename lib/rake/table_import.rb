require "active_record"
require "activerecord-import"
require "table_utils/progress"
require "rake/logger"

module Rake::DSL
  def table_import args, &block
    table_name = args.keys[0]

    task args.extract!(table_name) do |t|
      input_path = t.prerequisites[0]
      conn = ActiveRecord::Base.connection

      unless conn.table_exists? table_name
        logger.info "Importing #{table_name} from #{input_path}"
        begin
          conn.create_table table_name, &block
          model = Class.new(ActiveRecord::Base) { self.table_name = table_name }
          args[:csv] ||= {}
          args[:csv][:headers] ||= model.column_names.
            reject{|c|%w(id created_at updated_at).include? c}
          common_columns = model.column_names & args[:csv][:headers]

          csv = CSV.open input_path, args[:csv]
          csv.shift

          batch = []
          TableUtils::Progress.over csv do |row, bar|
            batch << common_columns.map{ |c| row[c] }
            if batch.count >= 1000 || bar.finished?
              model.import common_columns, batch, validate: false
              batch = []
            end
          end

        rescue
          if conn.table_exists? table_name
            logger.warn "dropping #{table_name} due to errors during import"
            conn.drop_table table_name
          end
          raise
        end
      end
    end
  end
end
