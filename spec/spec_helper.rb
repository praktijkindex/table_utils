require "active_record"
require "csv"
require "ruby-progressbar"

def fixture basename
  File.expand_path("../fixtures/#{basename}", __FILE__)
end

shared_context "planets" do
  let(:planets_table) {
    CSV.read( fixture("table.csv"),
              headers: true,
              converters: :numeric )
       .map &:to_hash
  }
  let(:planets) { planets_table.map{|row| row["planet"]} }
  let(:planet_headers) { planets_table[0].keys }
end

shared_context "silent_progress" do
  let(:dummy_io) { StringIO.new }
  before(:each) { ProgressBar::Base.any_instance.stub(:output) { dummy_io } }
end

shared_context "in-memory db" do
  around(:each) do |example|
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
    ActiveRecord::Base.transaction {
      example.run
      raise ActiveRecord::Rollback, "clear the database"
    }
  end
  let(:conn) { ActiveRecord::Base.connection }
end

shared_examples "imports a table" do
  let(:model) { Class.new(ActiveRecord::Base) { self.table_name = :planets } }
  let(:records_without_id) { model.all.map{|r| r.attributes.tap{|h| h.delete("id")}} }
  it "imports a table" do
    expect( conn.table_exists? :planets ).to be_true
    expect( model.column_names ).to match_array planet_headers + %w(id)
    expect( records_without_id ).to match_array planets_table
  end
end

