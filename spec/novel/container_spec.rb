RSpec.describe Novel::Container do
  let(:container) { described_class.new }

  describe '#register' do
    it "stores dependency by symbol key as a sting key" do
      container.register(:new_key, :value)
      expect(container._container).to eq('new_key' => :value)
    end

    it "stores dependency by sting key as a sting key" do
      container.register('new_key', :value)
      expect(container._container).to eq('new_key' => :value)
    end
  end

  describe '#resolve' do
    before { container.register(:new_key, :value) }

    it { expect(container.resolve(:new_key)).to eq(:value) }
    it { expect(container.resolve('new_key')).to eq(:value) }

    it { expect(container.resolve(:missing_key)).to eq(nil) }
  end
end
