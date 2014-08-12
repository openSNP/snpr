# Requires something like this in the sudoers file:
#
#   snpr ALL=NOPASSWD: /usr/sbin/service sidekiq-manager *
#
namespace :sidekiq do
  [:start, :stop, :restart, :status].each do |name|
    desc "#{name}s sidekiq"
    task(name) { run "sudo /usr/sbin/service sidekiq-manager #{name}" }
  end
end
