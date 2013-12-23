require "rake"
require "rake/table_import"
include Rake::DSL

describe "Rake::DSL.table_import" do
  include_context "planets"
  let(:rake) { Rake::Application.new }
  let(:conn) { ActiveRecord::Base.connection }
  let(:table) { :planets }
  let(:model) { Class.new(ActiveRecord::Base) { self.table_name = :planets } }
  let(:records_without_id) { model.all.map{|r| r.attributes.tap{|h| h.delete("id")}} }
  before {
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
    Rake.application = rake
    table_import table => fixture("table.csv"),
      csv: { headers: %w(planet earth_masses jupiter_masses) } do |t|
      t.string :planet
      t.float :earth_masses
      t.float :jupiter_masses
    end
  }

  it "imports a table" do
    expect( conn.table_exists? :planets ).to be_false
    rake[:planets].invoke
    expect( conn.table_exists? :planets ).to be_true
    expect( model.column_names ).to match_array planet_headers + %w(id)
    expect( records_without_id ).to match_array planets_table
  end
end
