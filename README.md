# wordpress-cluster

Installs and configures a wordpress cluster. This cookbooks is highly
opinionated, and assumes you are conforming to our environment.

## LWRPs

This cookbook is intended to be consumed through its LWRPs, and therefore
doesn't include any recipes. Here is an overview of the LWRPs provided:

**Note:** The first attribute listed for each LWRP is also the name attribute.

### wordpress_cluster_app

**Attributes:**

| Name             | Description                                                      | Type                        | Required | Default  |
| ---------------- | ---------------------------------------------------------------- | --------------------------- | -------- | -------- |
| app_name         | Name of the application.                                         | String                      | true     | N/A      |
| deployment_user  | User that deploys the application.                               | String                      | false    | 'deploy' |
| deployment_group | Group that deploys the application.                              | String                      | false    | 'deploy' |
| web_root         | Directory where app is server (relative to the root of the repo) | String                      | false    | 'web'    |
| server_name      | ServerName in Apache config.                                     | String                      | true     | N/A      |
| server_aliases   | List of ServerAlias in Apache config.                            | Array                       | false    | nil      |
| scm              | Source code management tool used for the project                 | String ('git' or 'hg' only) | true     | N/A      |
| development      | Development flag for configuring local dev machines.             | Boolean                     | false    | false    |

**Example:**

```ruby
wordpress_cluster_app 'my-app' do
  server_name 'my-app.com'
  scm 'git'
end
```

### wordpress_cluster_database

**Attributes:**

| Name                | Description                                          | Type    | Required | Default     |
| ------------------- | ---------------------------------------------------- | ------- | -------- | ----------- |
| db_name             | Name of the MySQL database.                          | String  | true     | N/A         |
| user                | MySQL user that owns the database.                   | String  | true     | N/A         |
| user_host           | Host the database is on.                             | String  | false    | 'localhost' |
| user_password       | Password for MySQL user that owns the database.      | String  | true     | N/A         |
| mysql_root_password | Password for MySQL root user.                        | String  | true     | N/A         |
| development         | Development flag for configuring local dev machines. | Boolean | false    | false       |

**Example:**

```ruby
wordpress_cluster_database 'my_app_production' do
  user 'my-app'
  user_host '%'
  user_password 'my-app-password'
  mysql_root_password 'my-root-password'
end
```

### wordpress_cluster_lb

**Attributes:**

| Name                  | Description                                         | Type                          | Required | Default |
| --------------------- | --------------------------------------------------- | ----------------------------- | -------- | ------- |
| keepalived_state      | Keepalived state (e.g. 'MASTER').                   | String ('MASTER' or 'BACKUP') | false    | nil     |
| keepalived_priority   | Keepalived state priority (e.g. 100).               | String                        | false    | nil     |
| keepalived_virtual_ip | Virtual IP address shared between keepalived nodes. | String                        | false    | nil     |
| keepalived_interface  | Interface that Virtual IP should be assigned to.    | String                        | false    | nil     |
| keepalived_auth_pass  | Auth password for keepalived.                       | String                        | false    | nil     |
| enable_keepalived     | Whether or not keepalived should be enabled.        | Boolean                       | false    | true    |
| sites                 | List of sites to configure in the haproxy.cfg.      | Array                         | true     | N/A     |
| basic_auth_users      | List of users to configure for basic auth.          | Array                         | false    | nil     |

**Note:** All keepalived attributes are required if enable_keepalived is true.

**Example:**

```ruby
wordpress_cluster_lb 'MASTER' do
  keepalived_priority '101'
  keepalived_virtual_ip '1.2.3.4'
  keepalived_interface 'eth1'
  keepalived_auth_pass 'my-auth-pass'
  sites [{ name: 'my-app', host: 'my-app.com', service: 'apache2' }]
end
```

### wordpress_cluster_repl_config

**Attributes:**

| Name         | Description                              | Type   | Required | Default |
| ------------ | ---------------------------------------- | ------ | -------- | ------- |
| name         | Name of repl configuration.              | String | true     | N/A     |
| csync2_key   | Key used for csync2.                     | String | true     | N/A     |
| csync2_hosts | List of hosts to sync with csync2.       | Array  | true     | N/A     |
| synced_dirs  | List of directories to sync with csync2. | Array  | true     | N/A     |

**Example:**

```ruby
wordpress_cluster_repl_config 'main' do
  csync2_key 'a5HuyFhmKThg.aOS_iNr8N_UOMvp6VLd.AnSL.PvP5SzckPpEYyMaWDP2Jv5t2H6'
  csync2_hosts [{ name: 'web01', ip_address: '1.2.3.4' },
                { name: 'web02', ip_address: '2.3.4.5' }]
  synced_dirs ['/var/www/my-app/shared/web/app/uploads']
end
```
