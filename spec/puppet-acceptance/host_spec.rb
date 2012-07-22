require 'spec_helper'
require 'ostruct'

#
#
# Shouldn't Host and a bunch of other crap in this harness decend from Struct too!?!?!
#
#
#
class MockConfig < Struct.new(:CONFIG, :HOSTS)
  def initialize(conf, hosts, is_pe = false)
    @is_pe = is_pe
    super conf, hosts
  end

  def is_pe?
    @is_pe
  end
end

module PuppetAcceptance
  describe Host do
    let(:config)  { MockConfig.new({}, {'name' => {'platform' => @platform}}, @pe)}
    let(:options) { Hash.new                                                      }
    let(:host)    { Host.create 'name', options, config                           }

    it 'creates a windows host given a windows config' do
      @platform = 'windows'
      expect( host ).to be_a_kind_of Windows::Host
    end

    it( 'defaults to a unix host' ) { expect( host ).to be_a_kind_of Unix::Host }

    it 'can be read like a hash' do
      expect { host['value'] }.to_not raise_error NoMethodError
    end

    it 'can be written like a hash' do
      host['value'] = 'blarg'
      expect( host['value'] ).to be === 'blarg'
    end


    it 'EXEC!'



    context 'merging defaults' do
      it 'knows the difference between foss and pe' do
        @pe = true
        expect( host['puppetpath'] ).to be === '/etc/puppetlabs/puppet'
      end

      it 'correctly merges network configs over defaults?' do
        overridden_config = MockConfig.new( {'puppetpath'=> '/i/do/what/i/want'},
                                            {'name' => {} },
                                              false )
        merged_host = Host.create 'name', options, overridden_config
        expect( merged_host['puppetpath'] ).to be === '/i/do/what/i/want'
      end

      it 'correctly merges host specifics over defaults' do
        overriding_config = MockConfig.new( {},
                                            {'name' => {
                                              'puppetpath' => '/utter/awesomeness'}
                                            }, true )

        merged_host = Host.create 'name', options, overriding_config
        expect( merged_host['puppetpath'] ).to be === '/utter/awesomeness'
      end
    end
  end
end
