require "table_utils/limit_loops"
include TableUtils

describe LimitLoops do
  let(:limit_value) { 5 }
  let(:default_count) { 10 }

  describe "#total" do
    subject { LimitLoops.new limit_value }
    its(:total) { should == limit_value }
  end

  describe "::limit_loops + #check!" do
    it "limits number of iterations to limit value" do
      counter = 0
      LimitLoops.to limit_value do |limit|
        default_count.times do
          counter += 1
          limit.check!
        end
      end
      expect(counter).to eq limit_value
    end
    it "doesn't limit number of iterations when given nil" do
      counter = 0
      LimitLoops.to nil do |limit|
        default_count.times do
          counter += 1
          limit.check!
        end
      end
      expect(counter).to eq default_count
    end
  end
end
