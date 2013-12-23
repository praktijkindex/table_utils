require "csv/stream"

describe CSV::Stream do
  include_context "planets"
  subject { CSV::Stream.new fixture("table.csv") }
  its(:count) { should == planets.count }

  describe "#each" do
    it "iterates over rows" do
      first_column = []
      subject.each { |row| first_column << row[0] }
      expect( first_column ).to eq ["planet", *planets]
    end
  end

  describe "CSV.stream" do
    subject { CSV.stream fixture("table.csv") }
    it { should be_a CSV::Stream }
    it "iterates if block given" do
      first_column = []
      CSV.stream(fixture "table.csv") { |row| first_column << row[0] }
      expect( first_column ).to eq ["planet", *planets]
    end
  end
end
