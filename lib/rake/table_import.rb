require "data_source"

module Rake::DSL
  def table_import args, &block
    table_name = args.keys[0]
    progress_opts = args[:progress] || {}
    task args.extract!(table_name) do |t|
      source = DataSource.new table_name, t.prerequisites[0], args[:csv], &block
      unless source.table_exists?
        begin
          logger.info { "Importing #{source.table_name} from #{source.input_path}" }
          source.import progress_opts
        rescue Exception => e
          logger.fatal { "Error during import of '#{source.table_name}'" }
          logger.fatal { e }
          if source.table_exists?
            logger.warn { "Dropping #{table_name} due to errors during import" }
            source.drop_table
          end
        end
      end
    end
  end
end
