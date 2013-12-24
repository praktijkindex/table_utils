require "data_source"

describe DataSource do
  include_context "planets"
  include_context "silent_progress"
  include_context "in-memory db"

  context "with explicit csv headers" do
    let(:source) {
      DataSource.new :planets, fixture("table.csv"),
        headers: %w(planet earth_masses jupiter_masses)  do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    }
    before { source.import }
    include_examples "imports a table"
  end

  context "with implicit csv headers" do
    let(:source) {
      DataSource.new :planets, fixture("table.csv") do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    }
    before { source.import }
    include_examples "imports a table"
  end

  context "with csv headers from the first row" do
    let(:source) {
      DataSource.new :planets, fixture("table.csv"), headers: true do |t|
        t.string :planet
        t.float :earth_masses
        t.float :jupiter_masses
      end
    }
    before { source.import }
    include_examples "imports a table"
  end

end
