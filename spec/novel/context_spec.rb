RSpec.describe Novel::Context do
  let(:context) { described_class.new(id: '123', params: params) }
  let(:params) { { key: 'value' } }

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
end
