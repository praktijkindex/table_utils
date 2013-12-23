require "rake"
require "rake/table_import"
include Rake::DSL

describe "Rake::DSL.table_import" do
  include_context "planets"
  include_context "silent_progress"
  let(:rake) { Rake::Application.new }
  let(:conn) { ActiveRecord::Base.connection }
  let(:model) { Class.new(ActiveRecord::Base) { self.table_name = :planets } }
  let(:records_without_id) { model.all.map{|r| r.attributes.tap{|h| h.delete("id")}} }

  around(:each) do |example|
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
    conn.transaction { example.run }
  end

  before(:each) do
    Rake.application = rake
    logger.level = Logger::UNKNOWN
  end

  shared_examples "imports a table" do
    it "imports a table" do
      expect( conn.table_exists? :planets ).to be_false
      rake[:planets].invoke
      expect( conn.table_exists? :planets ).to be_true
      expect( model.column_names ).to match_array planet_headers + %w(id)
      expect( records_without_id ).to match_array planets_table
    end
    it "cleans up on errors" do
      ActiveRecord::Base.stub(:import) { raise RuntimeError.new "oops" }
      expect { rake[:planets].invoke }.to raise_error
      expect( conn.table_exists? :planets ).to be_false
    end
  end

  context "with explicit csv headers" do
    before(:each) do
      table_import :planets => fixture("table.csv"),
        csv: { headers: %w(planet earth_masses jupiter_masses) } do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    end
    include_examples "imports a table"
  end

  context "with implicit csv headers" do
    before(:each) do
      table_import :planets => fixture("table.csv") do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    end
    include_examples "imports a table"
  end
end
