require "csv"

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
