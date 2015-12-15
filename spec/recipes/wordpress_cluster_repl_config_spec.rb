require 'spec_helper'

describe 'wordpress-cluster-test::wordpress_cluster_repl_config' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['wordpress_cluster_repl_config']).converge(described_recipe)
  end

  it 'should create wordpress_cluster_repl_config[main]' do
    expect(chef_run).to create_wordpress_cluster_repl_config('main')
  end

  it 'should create file[csync2.key]' do
    expect(chef_run).to create_file('csync2.key').with_content('a5HuyFhmKThg.aOS_iNr8N_UOMvp6VLd.AnSL.PvP5SzckPpEYyMaWDP2Jv5t2H6')
  end

  it 'should create csync2_config[/etc/csync2.cfg]' do
    expect(chef_run).to create_csync2_config('/etc/csync2.cfg')
  end

  it 'should create lsyncd_config[/etc/lsyncd/lsyncd.conf.lua' do
    expect(chef_run).to create_lsyncd_config('/etc/lsyncd/lsyncd.conf.lua')
  end

  it 'should do nothing to service[consul]' do
    consul = chef_run.service('consul')
    expect(consul).to do_nothing
  end
end
