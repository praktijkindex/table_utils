describe PsqlSchema do
  describe "path" do
    it "returns current schema search path" do
      ActiveRecord::Base.connection.schema_search_path = "public"
      expect( PsqlSchema.path ).to eq "public"
      ActiveRecord::Base.connection.schema_search_path = "'$user',public"
      expect( PsqlSchema.path ).to eq "'$user',public"
    end
  end

  describe "path=" do
    it "sets current schema search path" do
      PsqlSchema.path = "public"
      expect( ActiveRecord::Base.connection.schema_search_path ).to eq "public"
      PsqlSchema.path = "'$user',public"
      expect( ActiveRecord::Base.connection.schema_search_path ).to eq "'$user',public"
    end
  end

  describe 'create' do
    it "creates a new schema" do
      PsqlSchema.create 'new_schema'
      expect {
        ActiveRecord::Base.connection.schema_search_path = "new_schema"
      }.to_not raise_error
      expect( ActiveRecord::Base.connection.schema_search_path ).to eq "new_schema"
    end
  end

  describe 'exists?' do
    it "is true for existing schema" do
      expect( PsqlSchema.exists? "public" ).to be_true
    end

    it "is false for non-existing schema" do
      expect( PsqlSchema.exists? "non_exisiting_schema" ).to be_false
    end
  end

  describe 'drop' do
    it 'drops a schema' do
      PsqlSchema.create 'foo'
      expect( PsqlSchema.exists? 'foo' ).to be_true
      PsqlSchema.drop 'foo'
      expect( PsqlSchema.exists? 'foo' ).to be_false
    end
  end

  describe 'with_path' do
    before :each do
      @new_paths = []
      @old_path = PsqlSchema.path = "'$user', public"
      PsqlSchema.create 'new_schema'
    end
    after :each do
      PsqlSchema.drop 'new_schema'
    end

    it 'sets search path temporarily' do
      PsqlSchema.with_path 'new_schema' do
        @new_paths << PsqlSchema.path
      end
      expect( @new_paths[0] ).to eq 'new_schema'
      expect( PsqlSchema.path ).to eq @old_path
    end

    it 'can nest' do
      PsqlSchema.with_path 'new_schema' do
        @new_paths << PsqlSchema.path
        PsqlSchema.with_path 'public' do
          @new_paths << PsqlSchema.path
        end
      end
      expect( @new_paths[0] ).to eq 'new_schema'
      expect( @new_paths[1] ).to eq 'public'
      expect( PsqlSchema.path ).to eq @old_path
    end

    it 'supports :prepend' do
      PsqlSchema.with_path prepend: "new_schema" do
        @new_paths << PsqlSchema.path
      end
      expect(@new_paths[0]).to eq "new_schema,#{@old_path}"
      expect( PsqlSchema.path ).to eq @old_path
    end

  end
end
