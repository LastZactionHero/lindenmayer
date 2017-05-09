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

      describe 'context sensitive systems' do
        it 'iterates properly for a context-sensitive system' do
          lsystem = Lindenmayer::LSystem.new('A[X]BC', 'A<B>C' => 'Z')
          expect(lsystem.iterate).to eq('A[X]ZC')
        end

        it 'iterates properly for a right-side cs system' do
          lsystem = Lindenmayer::LSystem.new('ABC[DE][SG[HI[JK]L]MNO]', 'S>G[H]M' => 'Z')
          expect(lsystem.iterate).to eq('ABC[DE][ZG[HI[JK]L]MNO]')
        end

        it 'iterates properly for a left-side cs system' do
          lsystem = Lindenmayer::LSystem.new('A+B+C[DE][-S-G[HI[JK]L-]M-NO]', 'BC<S' => 'Z')
          # ignoredSymbols: '+-'
          expect(lsystem.iterate).to eq('A+B+C[DE][-Z-G[HI[JK]L-]M-NO]')
        end

        it 'does not transform on a non-matching case' do
          lsystem = Lindenmayer::LSystem.new('A[X]BD', 'A<B>C' => 'Z')
          expect(lsystem.iterate).to eq('A[X]BD')
        end
      end
    end
  end
end
