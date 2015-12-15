require 'spec_helper'

describe 'wordpress-cluster-test::wordpress_cluster_app' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['wordpress_cluster_app']) do |node|
      node.set['wordpress_cluster_test']['bedrock'] = false
    end.converge(described_recipe)
  end

  it 'should create wordpress_cluster_app[my-app]' do
    expect(chef_run).to create_wordpress_cluster_app('my-app')
  end

  it 'should include the apt::default recipe' do
    expect(chef_run).to include_recipe('apt::default')
  end

  it 'should include the unzip::default recipe' do
    expect(chef_run).to include_recipe('unzip::default')
  end

  it 'should create capistrano_user[deploy]' do
    expect(chef_run).to create_capistrano_user('deploy')
  end

  it 'should create capistrano_wordpress_app[my-app]' do
    expect(chef_run).to create_capistrano_wordpress_app('my-app')
  end

  context 'when vanilla wordpress' do
    it 'should create directory[/var/www/my-app/shared/web]' do
      expect(chef_run).to create_directory('/var/www/my-app/shared/web')
    end

    it 'should create template[/var/www/my-app/shared/web/wp-config.php.ctmpl' do
      expect(chef_run).to create_template('/var/www/my-app/shared/web/wp-config.php.ctmpl')
    end

    it 'should create consul_template_config[my-app_wp-config]' do
      expect(chef_run).to create_consul_template_config('my-app_wp-config')
    end
  end

  context 'when bedrock' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['wordpress_cluster_app']) do |node|
        node.set['wordpress_cluster_test']['bedrock'] = true
      end.converge(described_recipe)
    end

    it 'should create capistrano_shared_file[.env.ctmpl]' do
      expect(chef_run).to create_capistrano_shared_file('.env.ctmpl')
    end

    it 'should create consul_template_config[my-app_env]' do
      expect(chef_run).to create_consul_template_config('my-app_env')
    end
  end

  it 'should restart service[consul-template]' do
    expect(chef_run).to restart_service('consul-template')
  end

  it 'should restart service[apache2]' do
    expect(chef_run).to restart_service('apache2')
  end
end
