include_recipe "nginx"
include_recipe "unicorn"

gem_package "bundler"

common = { :name => "rails_app", :app_root => "/u/apps/rails_app"}

directory common[:app_root] do
	owner "vagrant"
	recursive true
end

directory common[:app_root] + "/current" do
	owner "vagrant"
end

%w(config log tmb sockets pids).each do |dir|
	directory "#{common[:app_root]}/shared/#{dir}" do
		owner "vagrant"
		recursive true
		mode 0755
	end
end

template "#{node[:unicorn][:config_path]}/#{common[:name]}.conf.rb" do
	mode 0644
	source "unicorn.conf.erb"
	variables common
end

nginx_config_path = "/etc/nginx/sites-available/#{common[:name]}.conf"

template nginx_config_path do
	mode 0644
	source "nginx.conf.erb"
	variables common.merge(:server_names => "brunosbarros.test")
	notifies :reload, "service[nginx]"
end

nginx_site "rails_app" do
	config_path nginx_config_path
	action :enable
end