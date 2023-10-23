# frozen_string_literal: true
require 'spec_helper'
require_relative '../lib/text_view.rb'

# Define the SampleFeature module directly in the spec
module SampleFeature
  def sample_method
    "I'm from SampleFeature"
  end
end

RSpec.describe TextView::Window do
  describe '.include_feature (class method)' do
    before do
      described_class.include_feature(SampleFeature)
    end
    after(:each) do
      described_class.class_variable_set(:'@@included_features', [])
      described_class.singleton_class.class_eval do
        remove_method :sample_method if method_defined?(:sample_method)
      end
    end

    it 'includes the feature in all new instances' do
      window1 = described_class.new
      window2 = described_class.new

      expect(window1).to respond_to(:sample_method)
      expect(window2).to respond_to(:sample_method)
    end
  end

  describe '#include_feature (instance method)' do
    let(:parent_window) { described_class.new }
    let(:child_window) { parent_window.create_child }
    let(:unrelated_window) { described_class.new }

    before do
      parent_window.include_feature(SampleFeature)
    end

    after(:each) do
      [parent_window, child_window, unrelated_window].each do |window|
        window.singleton_class.class_eval do
          remove_method :sample_method if method_defined?(:sample_method)
        end
      end
    end
  end
end
