# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:alternatives).provider(:chkconfig) do
  def my_fixture_alternatives
    Dir.glob(File.join('spec', 'fixtures', 'unit', 'provider', 'alternatives', 'chkconfig', 'alternatives', '*'))
  end

  def my_fixture_display(type, path)
    File.join('spec', 'fixtures', 'unit', 'provider', 'alternatives', 'chkconfig', type, path)
  end

  def my_fixture_read(type, path)
    File.read(my_fixture_display(type, path))
  end

  let(:stub_selections) do
    {
      'sample' => { path: '/opt/sample1' },
      'testcmd' => { path: '/opt/testcmd1' }
    }
  end

  describe '.all' do
    it 'List all alternatives in folder /var/lib/alternatives' do
      expect(described_class).to receive(:list_alternatives).and_return(my_fixture_alternatives)
      expect(described_class).to receive(:update).with('--display', 'sample').and_return(my_fixture_read('display', 'sample'))
      expect(described_class).to receive(:update).with('--display', 'testcmd').and_return(my_fixture_read('display', 'testcmd'))
      described_class.all
    end

    describe 'returning data' do
      subject { described_class.all }

      before do
        allow(described_class).to receive(:list_alternatives).and_return(my_fixture_alternatives)
        allow(described_class).to receive(:update).with('--display', 'sample').and_return(my_fixture_read('display', 'sample'))
        allow(described_class).to receive(:update).with('--display', 'testcmd').and_return(my_fixture_read('display', 'testcmd'))
      end

      it { is_expected.to be_a Hash }
      it { expect(subject['sample']).to eq(mode: 'manual', path: '/opt/sample2') }
      it { expect(subject['testcmd']).to eq(mode: 'manual', path: '/opt/testcmd1') }
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
    subject { described_class.new(name: 'sample') }

    let(:resource) { Puppet::Type.type(:alternatives).new(name: 'sample') }

    before do
      allow(Puppet::Type.type(:alternatives)).to receive(:defaultprovider).and_return(described_class)
      allow(described_class).to receive(:update).with('--display', 'sample').and_return(my_fixture_read('display', 'sample'))
      allow(described_class).to receive(:update).with('--display', 'testcmd').and_return(my_fixture_read('display', 'testcmd'))
      resource.provider = subject
      allow(described_class).to receive(:all).and_return(stub_selections)
    end

    it '#path retrieves the path from class.all' do
      expect(subject.path).to eq('/opt/sample1')
    end

    it '#path= updates the path with alternatives --set' do
      expect(subject).to receive(:update).with('--set', 'sample', '/opt/sample1')
      subject.path = '/opt/sample1'
    end

    it '#mode=(:auto) calls alternatives --auto' do
      expect(subject).to receive(:update).with('--auto', 'sample')
      subject.mode = :auto
    end

    it '#mode=(:manual) calls alternatives --set with current value' do
      expect(subject).to receive(:path).and_return('/opt/sample2')
      expect(subject).to receive(:update).with('--set', 'sample', '/opt/sample2')
      subject.mode = :manual
    end
  end
end
