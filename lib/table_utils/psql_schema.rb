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
          orig_error = nil
          old_path = PsqlSchema.path
          PsqlSchema.path = case path
                            when String
                              path
                            when Hash
                              [path[:prepend] , *PsqlSchema.path.split(",")].join(",")
                            end
          yield
        rescue Exception => e
          orig_error = e
          raise
        ensure
          begin
            PsqlSchema.path = old_path
          rescue Exception => e
            if orig_error
              raise orig_error
            else
              raise
            end
          end
        end
      end
    end
  end
end
