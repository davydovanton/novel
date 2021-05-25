RSpec.describe Novel::Context do
  let(:context) { described_class.new(id: '123', params: params) }
  let(:params) { { key: 'value' } }

  describe '#failed?' do
    subject { context.failed? }

    context 'when saga completed one or more compensation step' do
      before { context.save_compensation_state(:test_failed_step, { a: 1 }) }

      it { expect(subject).to be true }
    end

    context 'when saga did not completed one or more compensation step' do
      it { expect(subject).to be false }
    end
  end

  describe '#save_state and #step' do
    it 'store completed step and step result' do
      context.save_state(:test_saga_spep, { result: true })

      expect(context.last_competed_step).to eq(:test_saga_spep)
      expect(context.step(:test_saga_spep)).to eq(result: true)
    end

    it 'store last completed step and step result' do
      context.save_state(:test_saga_spep, { result: true })
      context.save_state(:next_test_saga_spep, { result: false })

      expect(context.last_competed_step).to eq(:next_test_saga_spep)
      expect(context.step(:test_saga_spep)).to eq(result: true)
      expect(context.step(:next_test_saga_spep)).to eq(result: false)
    end
  end

  describe '#save_compensation_state and #compensation_step' do
    it 'store completed step and step result' do
      context.save_compensation_state(:test_saga_compensation_spep, { result: true })

      expect(context.last_competed_compensation_step).to eq(:test_saga_compensation_spep)
      expect(context.compensation_step(:test_saga_compensation_spep)).to eq(result: true)
    end

    it 'store last completed step and step result' do
      context.save_compensation_state(:test_saga_compensation_spep, { result: true })
      context.save_compensation_state(:next_test_saga_compensation_spep, { result: false })

      expect(context.last_competed_compensation_step).to eq(:next_test_saga_compensation_spep)
      expect(context.compensation_step(:test_saga_compensation_spep)).to eq(result: true)
      expect(context.compensation_step(:next_test_saga_compensation_spep)).to eq(result: false)
    end
  end
end
