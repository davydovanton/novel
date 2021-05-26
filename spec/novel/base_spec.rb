RSpec.describe Novel::Base do
  let(:base) { described_class.new(logger: Object.new, repository: repository, timeout: 10) }

  let(:repository) { Object.new }

  describe 'repository in the constructor' do
    subject { base.repository }

    context 'when repository is symbol' do
      context 'and repository already exists in the library' do
        let(:repository) { :memory }

        it { expect(subject).to be_a(Novel::SagaRepository) }
      end

      context 'and repository does not exist in the library' do
        let(:repository) { :nothing }

        it { expect{ subject }.to raise_error(Novel::InvalidRepositoryError, "Repository 'nothing' does not exist in Novel. Please, use custom object insted") }
      end
    end

    context 'when repository is a object' do
      let(:repository) { Object.new }

      it { expect(subject).to be(repository) }
    end
    
  end

  describe '#build' do
    subject { base.build(name: 'test') }

    it { expect(subject).to be_a(Novel::WorkflowBuilder) }
  end
end
