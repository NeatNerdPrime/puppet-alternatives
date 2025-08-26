# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:alternatives).provider(:dpkg) do
  def my_fixture(path)
    File.join('spec', 'fixtures', 'unit', 'provider', 'alternatives', 'dpkg', path)
  end

  def my_fixture_read(path)
    File.read(my_fixture(path))
  end

  let(:stub_selections) do
    {
      'editor' => { mode: 'manual', path: '/usr/bin/vim.tiny' },
      'aptitude' => { mode: 'auto', path: '/usr/bin/aptitude-curses' }
    }
  end

  describe '.all' do
    it 'calls update-alternatives --get-selections' do
      expect(described_class).to receive(:update).with('--get-selections').and_return(my_fixture_read('get-selections'))
      described_class.all
    end

    describe 'returning data' do
      subject { described_class.all }

      before do
        allow(described_class).to receive(:update).with('--get-selections').and_return(my_fixture_read('get-selections'))
      end

      it { is_expected.to be_a Hash }
      it { expect(subject['editor']).to eq(mode: 'manual', path: '/usr/bin/vim.tiny') }
      it { expect(subject['aptitude']).to eq(mode: 'auto', path: '/usr/bin/aptitude-curses') }
    end
  end

  describe '.instances' do
    it 'delegates to .all' do
      stub_instance = instance_double(described_class)
      expect(described_class).to receive(:all).and_return(stub_selections)
      expect(described_class).to receive(:new).twice.and_return(stub_instance)
      described_class.instances
    end
  end

  describe 'instances' do
    subject { described_class.new(name: 'editor') }

    let(:resource) { Puppet::Type.type(:alternatives).new(name: 'editor') }

    before do
      allow(Puppet::Type.type(:alternatives)).to receive(:defaultprovider).and_return(described_class)
      resource.provider = subject
      allow(described_class).to receive(:all).and_return(stub_selections)
    end

    it '#path retrieves the path from class.all' do
      expect(subject.path).to eq('/usr/bin/vim.tiny')
    end

    it '#path= updates the path with update-alternatives --set' do
      expect(subject).to receive(:update).with('--set', 'editor', '/bin/nano')
      subject.path = '/bin/nano'
    end

    it '#mode=(:auto) calls update-alternatives --auto' do
      expect(subject).to receive(:update).with('--auto', 'editor')
      subject.mode = :auto
    end

    it '#mode=(:manual) calls update-alternatives --set with current value' do
      expect(subject).to receive(:path).and_return('/usr/bin/vim.tiny')
      expect(subject).to receive(:update).with('--set', 'editor', '/usr/bin/vim.tiny')
      subject.mode = :manual
    end
  end
end
