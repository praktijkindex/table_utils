require "data_source"
require "rake/logger"

module Rake::DSL
  def table_import args, &block
    table_name = args.keys[0]
    task args.extract!(table_name) do |t|
      source = DataSource.new table_name, t.prerequisites[0], args[:csv], &block
      unless source.table_exists?
        begin
          logger.info { "Importing #{source.table_name} from #{source.input_path}" }
          source.import
        rescue
          if source.table_exists?
            logger.warn { "dropping #{table_name} due to errors during import" }
            source.drop_table
          end
          raise
        end
      end
    end
  end
end
