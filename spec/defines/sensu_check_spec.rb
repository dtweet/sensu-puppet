require 'spec_helper'

describe 'sensu::check', :type => :define do
  let(:facts) { { :osfamily => 'RedHat' } }

  context 'without whitespace in name' do
    let(:title) { 'mycheck' }

    context 'defaults' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

      it { should contain_sensu_check('mycheck').with(
        :command     => '/etc/sensu/somecommand.rb',
        :interval    => 60
      ) }

    end

    context 'setting params' do
      let(:params) { {
        :command             => '/etc/sensu/command2.rb',
        :handlers            => ['/handler1', '/handler2'],
        :interval            => 10,
        :occurrences         => 5,
        :refresh             => 3600,
        :subscribers         => ['all'],
        :custom              => { 'a' => 'b', 'array' => [ 'c', 'd']},
        :type                => 'metric',
        :standalone          => true,
        :low_flap_threshold  => 10,
        :high_flap_threshold => 15,
        :timeout             => 0.5,
        :aggregate           => 'my_aggregate',
        :aggregates          => ['aggregate_1', 'aggregate_2'],
        :handle              => true,
        :publish             => true,
        :ttl                 => 30
      } }

      it { should contain_sensu_check('mycheck').with(
        :command             => '/etc/sensu/command2.rb',
        :handlers            => ['/handler1', '/handler2'],
        :interval            => 10,
        :occurrences         => 5,
        :refresh             => 3600,
        :subscribers         => ['all'],
        :custom              => { 'a' => 'b', 'array' => [ 'c', 'd']},
        :type                => 'metric',
        :standalone          => true,
        :low_flap_threshold  => 10,
        :high_flap_threshold => 15,
        :timeout             => 0.5,
        :aggregate           => 'my_aggregate',
        :aggregates          => ['aggregate_1', 'aggregate_2'],
        :handle              => true,
        :publish             => true,
        :ttl                 => 30
      ) }
    end

    context 'ensure absent' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb', :ensure => 'absent' } }

      it { should contain_sensu_check('mycheck').with_ensure('absent') }
    end
  end

  context 'with whitespace in name' do
    let(:title) { 'mycheck foobar' }
    context 'defaults' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

      it { should contain_sensu_check('mycheck_foobar').with(
        :command     => '/etc/sensu/somecommand.rb',
        :interval    => '60'
      ) }

      it { should contain_file('/etc/sensu/conf.d/checks/mycheck_foobar.json') }

    end
  end

  context 'with brackets in name' do
    let(:title) { 'mycheck (foo) bar' }
    context 'defaults' do
      let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

      it { should contain_sensu_check('mycheck_foo_bar').with(
        'command'     => '/etc/sensu/somecommand.rb',
        'interval'    => '60'
      ) }

      it { should contain_file('/etc/sensu/conf.d/checks/mycheck_foo_bar.json') }
    end
  end

  context 'notifications' do
    let(:title) { 'mycheck' }
    let(:params) { { :command => '/etc/sensu/somecommand.rb' } }

    context 'no client, sever, or api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => []) }
    end

    context 'only client' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => 'Class[Sensu::Client::Service]' ) }
    end

    context 'only server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => false, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => 'Class[Sensu::Server::Service]' ) }
    end

    context 'only api' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => 'Class[Sensu::Api::Service]' ) }
    end

    context 'client and api' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => false}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Api::Service]']) }
    end

    context 'client and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => false, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Server::Service]']) }
    end

    context 'api and server' do
      let(:pre_condition) { 'class {"sensu": client => false, api => true, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Server::Service]', 'Class[Sensu::Api::Service]']) }
    end

    context 'client, api, and server' do
      let(:pre_condition) { 'class {"sensu": client => true, api => true, server => true}' }
      it { should contain_sensu_check('mycheck').with(:notify => ['Class[Sensu::Client::Service]', 'Class[Sensu::Server::Service]', 'Class[Sensu::Api::Service]']) }
    end
  end

  context 'with subdue' do
    let(:title) { 'mycheck' }

    context 'defined' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
          :subdue  => {
            'begin' => '5PM PST',
            'end'   => '9AM PST'
          }
        }
      }

      it { should contain_sensu_check('mycheck').with_subdue( {'begin' => '5PM PST', 'end' => '9AM PST'}) }
    end

    context '=> \'absent\'' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
          :subdue  => 'absent'
        }
      }

      it { should contain_sensu_check('mycheck').with_subdue(:absent) }
    end

    context '= undef' do
      let(:params) {
        {
          :command => '/etc/sensu/somecommand.rb',
        }
      }

      it { should contain_sensu_check('mycheck').without_subdue }
    end
  end
end
