require "data_source"

describe DataSource do
  include_context "planets"
  include_context "silent_progress"
  include_context "in-memory db"

  let(:more_args) { [] }
  let(:source) {
    DataSource.new :planets, fixture("table.csv"), *more_args do
      define_table do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    end
  }
  before { source.import }
  let(:model) { Class.new(ActiveRecord::Base) { self.table_name = :planets } }
  let(:records_without_id) { model.all.map{|r| r.attributes.tap{|h| h.delete("id")}} }

  shared_examples "imports a table" do
    it "imports a table" do
      expect( conn.table_exists? :planets ).to be_true
      expect( model.column_names ).to match_array planet_headers + %w(id)
      expect( records_without_id ).to match_array planets_table
    end
  end

  context "with implicit csv headers" do
    include_examples "imports a table"
  end

  context "with explicit csv headers" do
    let(:more_args) { [headers: planet_headers] }
    include_examples "imports a table"
  end

  context "with csv headers from the first row" do
    let(:more_args) { [headers: true] }
    include_examples "imports a table"
  end

end
