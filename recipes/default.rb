
if node[:'nginx-site']
  node[:'nginx-site'].each do |k, v|
    template "#{node[:nginx][:dir]}/sites-available/#{k}" do
      source "site.conf.erb"
      variables(
        :server_name    => v[:server_name],
        :name           => k,
        :document_root  => v[:document_root],
        :params         => v
      )
    end
    if v[:ssl]
      cookbook_file "#{node[:nginx][:dir]}/#{v[:ssl][:certificate]}" do
        source v[:ssl][:certificate]
        owner node[:nginx][:user]
        mode 0600
      end
      cookbook_file "#{node[:nginx][:dir]}/#{v[:ssl][:certificate_key]}" do
        source v[:ssl][:certificate_key]
        owner node[:nginx][:user]
        mode 0600
      end
    end
    link "#{node[:nginx][:dir]}/sites-enabled/#{k}" do
      to "#{node[:nginx][:dir]}/sites-available/#{k}"
      notifies :restart, resources(:service => "nginx")
      not_if do ::File.symlink?( "#{node[:nginx][:dir]}/sites-enabled/#{k}") end
    end
  end
end
