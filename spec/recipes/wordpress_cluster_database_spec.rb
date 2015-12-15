require 'spec_helper'

describe 'wordpress-cluster-test::wordpress_cluster_database' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['wordpress_cluster_database']) do |node|
      node.set['wordpress_cluster_test']['development'] = false
    end.converge(described_recipe)
  end

  before do
    stub_command("mysql -u root -pmy-root-password -D mysql -e \"select User from user\" | grep my-app").and_return(false)
    stub_command("mysql -u my-app -pmy-app-password -e \"show databases\" | grep my_app_production").and_return(false)
  end

  it 'should create wordpress_cluster_database[my_app_production]' do
    expect(chef_run).to create_wordpress_cluster_database('my_app_production')
  end

  it 'should include the apt::default recipe' do
    expect(chef_run).to include_recipe('apt::default')
  end

  context 'development' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['wordpress_cluster_database']) do |node|
        node.set['wordpress_cluster_test']['development'] = true
      end.converge(described_recipe)
    end

    it 'should set node[mysql][server_root_password]' do
      server_root_password = chef_run.node['mysql']['server_root_password']
      expect(server_root_password).to eq('my-root-password')
    end

    it 'should include the mysql::server recipe' do
      expect(chef_run).to include_recipe('mysql::server')
    end
  end

  it 'should create the db user' do
    expect(chef_run).to run_execute("create db user 'my-app'")
  end

  it 'should create the db' do
    expect(chef_run).to run_execute("create db 'my_app_production'")
  end

  it 'should grant the user privileges on the db' do
    expect(chef_run).to run_execute("grant 'my-app' privileges on db 'my_app_production'")
  end

  it 'should flush privileges' do
    expect(chef_run).to run_execute('flush privileges')
  end
end
