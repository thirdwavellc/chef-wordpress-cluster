def create_wordpress_cluster_app(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:wordpress_cluster_app, :create, resource_name)
end

def create_wordpress_cluster_database(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:wordpress_cluster_database, :create, resource_name)
end

def create_wordpress_cluster_repl_config(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:wordpress_cluster_repl_config, :create, resource_name)
end
