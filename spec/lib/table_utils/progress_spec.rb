require "table_utils/progress"

include TableUtils

describe Progress do
  include_context "silent_progress"

  describe "::bar" do
    context "without block" do
      subject { Progress.bar }
      it { should be_a ProgressBar::Base }
    end

    context "with block" do
      it "should yield a ProgressBar::Base instance" do
        yielded = nil
        Progress.bar do |bar|
          yielded = bar
        end
        expect( yielded ).to be_a ProgressBar::Base
      end
    end
  end

  describe "::over" do
    let(:enum) { [:foo,:bar] }
    let(:yielded) { [] }
    it "iterates over supplied enum" do
      Progress.over enum, output: dummy_io do |item,bar|
        expect(bar).to be_a ProgressBar::Base
        expect(bar.total).to eq enum.count
        yielded << item
      end
      expect(yielded).to eq enum
    end
  end
end
