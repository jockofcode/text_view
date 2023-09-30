require 'spec_helper'
require_relative '../lib/text_view.rb'

RSpec.describe TextView::Window do
  before do
    allow(Curses).to receive(:cols).and_return(30)
    allow(Curses).to receive(:lines).and_return(30)
    allow(Curses).to receive(:getch)
    allow(Curses).to receive(:close_screen)
    allow(Curses).to receive(:init_screen)
    allow(Curses).to receive(:cbreak)
    allow(Curses).to receive(:noecho)
    allow(Curses).to receive(:start_color)
    allow(Curses).to receive(:init_pair)
    allow(Curses).to receive(:color_pair).and_return(true)
    allow(Curses).to receive(:attron)
    allow(Curses).to receive(:setpos)
    allow(Curses).to receive(:addstr)
    allow(Curses).to receive(:clear)
    allow(Curses).to receive(:stdscr).and_return(double('stdscr', keypad: nil))
    allow(Curses).to receive(:timeout=)
  end

  let(:parent_window) { described_class.new }
  let(:child_window) { parent_window.create_child }

  before do
    allow(parent_window).to receive(:init_window_dimensions)
    allow(parent_window).to receive(:init_screen)
    allow(child_window).to receive(:init_window_dimensions)
    allow(child_window).to receive(:init_screen)

    parent_window.pos_x = 10 # -5 from child x
    parent_window.pos_y = 10 # -5 from child y
    parent_window.width = 20 # edge at 29 abs_x, 14 in child.pos_x
    parent_window.height = 20 # edge at 29 abs_y, 14 in child.pos_y

    child_window.pos_x = 5  # relative to parent, 15 abs_x
    child_window.pos_y = 5  # relative to parent, 15 abs_y
    child_window.width = 30  # larger than parent, edge at 44 abs_x
    child_window.height = 30  # larger than parent, edge at 44 abs_y
  end
  describe '#in_window? for child window' do
    context 'when the point is inside both parent and child windows' do
      it 'is true for a point within both child and parent' do
        expect(child_window.in_window?(10, 10)).to be(true)
      end
    end

    context 'when the point is inside the child but outside the parent window' do
      it 'is false for a point within child but outside parent' do
        expect(child_window.in_window?(25, 25)).to be(false)
      end
    end

    context 'when the point is outside both windows' do
      it 'is false for a point far outside both child and parent' do
        expect(child_window.in_window?(-6, -6)).to be(false)
      end
    end

    context 'when the point is outside the child window' do
      it 'is false for a point just outside the child window' do
        expect(child_window.in_window?(-1, -1)).to be(false)
      end
    end

    context 'when the point is at a specific corner inside both windows' do
      it 'is true for the top-left corner of the child window' do
        expect(child_window.in_window?(0, 0)).to be(true)
      end
      it 'is true for the bottom-right corner of the child window that also falls within the parent' do
        expect(child_window.in_window?(14, 14)).to be(true)
      end
    end

    context 'when the point is at a corner inside the child but outside the parent' do
      it 'is false for the bottom-left corner just outside the parent but inside the child' do
        expect(child_window.in_window?(15, 15)).to be(false)
      end
    end

    context 'when the point is at an edge inside both windows' do
      it 'is true for a point on the top edge of the child window that also falls within the parent' do
        expect(child_window.in_window?(0, 14)).to be(true)
      end
      it 'is true for a point on the bottom edge of the child window that also falls within the parent' do
        expect(child_window.in_window?(14, 14)).to be(true)
      end
      it 'is true for a point on the left edge of the child window that also falls within the parent' do
        expect(child_window.in_window?(14, 0)).to be(true)
      end
      it 'is true for a point on the right edge of the child window that also falls within the parent' do
        expect(child_window.in_window?(14, 14)).to be(true)
      end
    end

    context 'when the point is at an edge inside the child but outside the parent' do
      it 'is false for a point just outside the parent but on the top edge of the child' do
        expect(child_window.in_window?(0, 15)).to be(false)
      end
      it 'is false for a point just outside the parent but on the left edge of the child' do
        expect(child_window.in_window?(15, 0)).to be(false)
      end
    end
  end
end
