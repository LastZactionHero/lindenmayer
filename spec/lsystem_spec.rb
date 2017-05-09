require 'rspec'
require './lib/lsystem'

describe 'LSystem' do
  describe 'iterate' do
    describe 'Basic string-based LSystem' do
      let(:koch_axiom_start) { 'F++F++F' }
      let(:kock_productions) do
        {
          'F' => 'F-F++F-F'
        }
      end
      let(:koch_lsystem) do
        Lindenmayer::LSystem.new(koch_axiom_start, kock_productions)
      end

      it 'should generate a string for the Koch-curve' do
        expect(koch_lsystem.iterate).to eq('F-F++F-F++F-F++F-F++F-F++F-F')
      end

      it 'iterates again' do
        koch_lsystem.iterate
        expect(koch_lsystem.iterate).to eq('F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F')
      end

      it 'takes an optional iteration count' do
        expect(koch_lsystem.iterate(2)).to eq('F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F++F-F++F-F-F-F++F-F')
      end
    end
  end
end
