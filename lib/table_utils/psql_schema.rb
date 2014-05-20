module TableUtils
  module PsqlSchema
    class << self
      def path
        connection.schema_search_path
      end

      def exists? schema_name
        connection.schema_exists? schema_name
      end

      def path= new_path
        connection.schema_search_path = new_path
      end

      def create schema_name
        connection.execute "CREATE SCHEMA #{schema_name};"
      end

      def drop schema_name
        connection.execute "DROP SCHEMA #{schema_name} CASCADE;"
      end

      def list
        sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*' order by nspname"
        connection.query(sql).flatten
      end

      def connection
        ActiveRecord::Base.connection
      end

      def with_path path
        begin
          old_path = PsqlSchema.path
          PsqlSchema.path = case path
                            when String
                              path
                            when Hash
                              [path[:prepend] , *PsqlSchema.path.split(",")].join(",")
                            end
          yield
        rescue Exception => e
          Rails.logger.error e
          Rails.logger.error e.backtrace.join("\n")
          throw e
        ensure
          PsqlSchema.path = old_path
        end
      end
    end
  end
end
