# -*- coding: utf-8 -*-
require 'spec_helper'

shared_examples_for "a file binder" do
  describe ".pathnames" do
    it do
      expect(@dummy.pathnames).to be_a_kind_of Array
    end

    it do
      expect(@dummy.pathnames.first).to be_a_kind_of Pathname
    end
  end

  describe ".files" do
    it do
      expect(@dummy.files).to be_a_kind_of Array
    end
  end

  describe ".directories" do
    it do
      expect(@dummy.directories).to be_a_kind_of Array
    end
  end

  describe ".entries" do
    it do
      expect(@dummy.entries).to be_a_kind_of Array
    end
  end
end

shared_examples_for "a binding directory" do
  describe ".files" do
    it do
      expect(@dummy.files).to have(3 + 3).items
    end
  end

  describe ".directories" do
    it do
      expect(@dummy.directories).to have(1).items
    end
  end

  describe ".entries" do
    it do
      expect(@dummy.entries).to have(7).items
    end
  end
end

describe FileBinder do
  context "when default" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
      end
    end

    it_behaves_like "a file binder"

    describe ".files" do
      it do
        expect(@dummy.files).to have(3).items
      end
    end

    describe ".directories" do
      it do
        expect(@dummy.directories).to have(1).items
      end
    end

    describe ".entries" do
      it do
        expect(@dummy.entries).to have(4).items
      end
    end
  end

  context "when recursive" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
        recursive true
      end
    end

    it_behaves_like "a file binder"
    it_behaves_like "a binding directory"
  end

  context "when specify extensions" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
        extensions :jpg, :avi
      end
    end

    it_behaves_like "a file binder"

    describe ".files" do
      it do
        expect(@dummy.files).to have(2).items
      end
    end

    describe ".directories" do
      it do
        expect(@dummy.directories).to have(1).items
      end
    end

    describe ".entries" do
      it do
        expect(@dummy.entries).to have(3).items
      end
    end
  end

  context "when specify pattern" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
        pattern /\.txt\z/
      end
    end

    it_behaves_like "a file binder"

    describe ".files" do
      it do
        expect(@dummy.files).to have(1).items
      end
    end

    describe ".directories" do
      it do
        expect(@dummy.directories).to have(0).items
      end
    end

    describe ".entries" do
      it do
        expect(@dummy.entries).to have(1).items
      end
    end
  end

  context "when specify command" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
        command :large, ->(entries) do
          entries.select{ |entry| !entry.directory? and entry.size > 0 }
        end
      end
    end

    it do
      expect(@dummy.large).to be_a_kind_of Array
    end

    it do
      expect(@dummy.large).to have(1).items
    end
  end

  context "when specify bad name command" do
    it do
      expect{
        Class.new(FileBinder) do
          bind "spec/dummy"
          command :entries, ->(entries){}
        end
      }.to raise_error
    end
  end

  context "when specify listen callback" do
    it do
      callback = Proc.new do |changes|
        changes
      end
      expect_any_instance_of(Listen::Listener).to receive(:start).once
      Class.new(FileBinder) do
        bind "spec/dummy"
        modified_on &callback
      end
    end
  end

  describe ".save" do
    let(:filename) do
      "spec/tmp"
    end

    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
      end
    end

    it do
      expect{ @dummy.save(filename) }.to change{ File.exist?(filename) }.from(false).to(true)
    end

    after do
      FileUtils.rm(filename)
    end
  end

  describe ".load" do
    let(:filename) do
      "spec/tmp"
    end

    before do
      dummy = Class.new(FileBinder) do
        bind "spec/dummy"
      end
      # cache
      dummy.entries 
      dummy.save(filename)


      @dummy = Class.new(FileBinder) do
        bind "spec/dummy"
        recursive true
      end

      @from = @dummy.entries
      @to = dummy.entries
    end

    it do
      expect{ @dummy.load(filename) }.to change{ @dummy.entries }.from(@from).to(@to)
    end
    
    after do
      FileUtils.rm(filename)
    end
  end

  describe "when specify multiple binds" do
    before do
      @dummy = Class.new(FileBinder) do
        bind "spec/dummy", "spec/dummy/directory"
      end
    end

    it_behaves_like "a file binder"
    it_behaves_like "a binding directory"
  end
end
