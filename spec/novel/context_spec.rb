RSpec.describe Novel::Context do
  let(:context) { described_class.new(id: '123', params: params, step_results: step_results, compensation_step_results: compensation_step_results) }

  let(:params) { { key: 'value' } }
  let(:step_results) { { test_step: { a: 1 } } }
  let(:compensation_step_results) { { compensation_test_step: { b: 1 } } }

  describe '#success?' do
    subject { context.success? }

    context 'when saga did not completed one or more compensation step' do
      it { expect(subject).to be true }
    end

    context 'when saga completed one or more compensation step' do
      let(:context) { described_class.new(id: '123', params: params, failed: true) }

      it { expect(subject).to be false }
    end
  end

  describe '#failed?' do
    subject { context.failed? }

    context 'when saga completed one or more compensation step' do
      let(:context) { described_class.new(id: '123', params: params, failed: true) }

      it { expect(subject).to be true }
    end

    context 'when saga did not completed one or more compensation step' do
      it { expect(subject).to be false }
    end
  end

  describe '#step' do
    subject { context.step(step) }

    context 'when saga step name registered' do
      let(:step) { :test_step }

      it { expect(subject).to eq(a: 1) }
    end

    context 'when saga step name does not registered' do
      let(:step) { :does_not_exist }

      it { expect(subject).to eq(nil) }
    end
  end

  describe '#completed_steps' do
    subject { context.completed_steps }

    it { expect(subject).to eq([:test_step]) }
  end

  describe '#compensation_step' do
    subject { context.compensation_step(step) }

    context 'when saga step name registered' do
      let(:step) { :compensation_test_step }

      it { expect(subject).to eq(b: 1) }
    end

    context 'when saga step name does not registered' do
      let(:step) { :does_not_exist }

      it { expect(subject).to eq(nil) }
    end
  end

  describe '#completed_compensation_steps' do
    subject { context.completed_compensation_steps }

    it { expect(subject).to eq([:compensation_test_step]) }
  end
end
