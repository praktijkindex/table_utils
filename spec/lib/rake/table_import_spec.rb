require "rake"
require "rake/table_import"
include Rake::DSL

describe "Rake::DSL.table_import" do
  let(:rake) { Rake::Application.new }

  before(:each) do
    Rake.application = rake
    task "path"
  end

  it "unrolls the arguments and passes them to DataSource constructor" do
    catch :done do
      DataSource.should_receive(:new).with(:table_name, "path", :csv_options).and_throw :done
      table_import :table_name => "path", csv: :csv_options
      rake[:table_name].invoke
    end
  end

  it "passes nil for csv_options if not supplied" do
    catch :done do
      DataSource.should_receive(:new).with(:table_name, "path", nil).and_throw :done
      table_import :table_name => "path"
      rake[:table_name].invoke
    end
  end

  shared_context "mock source" do
    let(:source) { double() }
    before { DataSource.stub(:new) { source } }
  end

  context "table doesn't exist" do
    include_context "mock source"
    before { source.stub(:table_exists?) { false } }
    it "import from the source" do
      expect(source).to receive(:import).with()
      table_import :table_name => "path"
      rake[:table_name].invoke
    end

    context "import fails" do
      before {
        source.stub(:import) {
          source.stub(:table_exists?) { true }
          raise RuntimeError, "mock import failure"
        }
      }
      it "should drop the table and reraise the exception" do
        expect(source).to receive(:drop_table)
        table_import :table_name => "path"
        expect{rake[:table_name].invoke}.to raise_error("mock import failure")
      end
    end
  end

  context "table exists" do
    include_context "mock source"
    before { source.stub(:table_exists?) { true } }
    it "doesn't import" do
      expect(source).not_to receive(:import)
      table_import :table_name => "path"
      rake[:table_name].invoke
    end
  end
end
