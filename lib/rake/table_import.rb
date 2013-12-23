require "active_record"
require "activerecord-import"
require "csv/stream"
require "table_utils/progress"
require "rake/logger"

module Rake::DSL
  def table_import args, &block
    table_name = args.keys[0]

    task args.extract!(table_name) do |t|
      input = t.prerequisites[0]
      conn = ActiveRecord::Base.connection

      unless conn.table_exists? table_name
        conn.transaction do
          logger.info "Importing #{table_name} from #{input}"
          begin
            conn.create_table table_name, &block
            model = Class.new(ActiveRecord::Base) { self.table_name = table_name }
            common_columns = model.column_names & args[:csv][:headers]
            csv = CSV::Stream.new input, args[:csv]||{}

            TableUtils::Progress.bar total: csv.count do |bar|
              batch = []
              seen_headers = false
              csv.each do |row|
                unless seen_headers
                  seen_headers = true
                  next
                end
                batch << common_columns.map{ |c| row[c] }
                if batch.count >= 1000
                  model.import common_columns, batch, validate: false
                  bar.progress += batch.count
                  batch = []
                end
              end

              if batch.count > 0
                model.import common_columns, batch, validate: false
                bar.progress += batch.count
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
end
