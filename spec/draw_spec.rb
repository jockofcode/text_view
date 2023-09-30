require 'spec_helper'
require_relative '../lib/text_view/draw'

describe TextView::Draw do
  describe '.line' do
    it 'returns an array of points for a line between two points' do
      points = described_class.line(0, 0, 2, 2, :white, :black)
      expect(points).to eq([[0, 0, '*'], [1, 1, '*'], [2, 2, '*']])
    end
  end

  describe '.circle' do
    it 'returns an array of points for a circle with given center and radius' do
      points = described_class.circle(0, 0, 4, 4, :white, :black)
      expect(points).to eq([[2.0, 10, "o", :white, :black], [3.0, 10, "o", :white, :black], [4.0, 8, "o", :white, :black], [4.0, 6, "o", :white, :black], [5.0, 4, "o", :white, :black], [5.0, 4, "o", :white, :black], [4.0, 2, "o", :white, :black], [4.0, 0, "o", :white, :black], [3.0, -2, "o", :white, :black], [2.0, -2, "o", :white, :black], [1.0, -2, "o", :white, :black], [0.0, 0, "o", :white, :black], [0.0, 2, "o", :white, :black], [-1.0, 4, "o", :white, :black], [-1.0, 4, "o", :white, :black], [0.0, 6, "o", :white, :black], [0.0, 8, "o", :white, :black], [1.0, 10, "o", :white, :black], [2.0, 10, "o", :white, :black]] )
    end
  end

  describe '.rectangle' do
    it 'returns an array of points for a rectangle with given top-left and bottom-right points' do
      points = described_class.rectangle(0, 0, 2, 2, :white, :black)
      expect(points).to eq([[0, 0, "-", :white, :black], [2, 0, "-", :white, :black], [0, 1, "-", :white, :black], [2, 1, "-", :white, :black], [0, 2, "-", :white, :black], [2, 2, "-", :white, :black], [0, 0, "|", :white, :black], [0, 2, "|", :white, :black], [1, 0, "|", :white, :black], [1, 2, "|", :white, :black], [2, 0, "|", :white, :black], [2, 2, "|", :white, :black], [0, 0, "+", :white, :black], [0, 2, "+", :white, :black], [2, 0, "+", :white, :black], [2, 2, "+", :white, :black]])
    end
  end
end
