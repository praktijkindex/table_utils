require "table_utils/progress"

include TableUtils

describe Progress do
  describe "::bar" do
    context "without block" do
      subject { Progress.bar }
      it { should be_a ProgressBar::Base }
    end

    context "with block" do
      Progress.bar do |bar|
        subject { bar }
        it { should be_a ProgressBar::Base }
      end
    end
  end

  describe "::over" do
    let(:enum) { [:foo,:bar] }
    let(:yielded) { [] }
    it "iterates over supplied enum" do
      Progress.over enum do |item,bar|
        expect(bar).to be_a ProgressBar::Base
        expect(bar.total).to eq enum.count
        yielded << item
      end
      expect(yielded).to eq enum
    end
  end
end
