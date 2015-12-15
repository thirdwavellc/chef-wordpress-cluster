#
# Cookbook Name:: wordpress-cluster-test
# Recipe:: wordpress_cluster_repl_config
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

wordpress_cluster_repl_config 'main' do
  csync2_key 'a5HuyFhmKThg.aOS_iNr8N_UOMvp6VLd.AnSL.PvP5SzckPpEYyMaWDP2Jv5t2H6'
  csync2_hosts [{ name: 'web01', ip_address: '1.2.3.4' },
                { name: 'web02', ip_address: '2.3.4.5' }]
  lsyncd_sync_id 'web01'
  synced_dirs ['/var/www/my-app/shared/web/app/uploads']
end

