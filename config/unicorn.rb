rack_root = File.expand_path('../../', __FILE__)
rack_env  = 'production'
pid_file   = "#{rack_root}/tmp/unicorn.pid"
socket_file= "#{rack_root}/tmp/unicorn.sock"
log_file   = "#{rack_root}/log/unicorn.log"
old_pid    = pid_file + '.oldbin'

FileUtils.mkdir_p("#{rack_root}/tmp")
FileUtils.mkdir_p("#{rack_root}/log")

working_directory rack_root

timeout 30

worker_processes 1

# Listen on a Unix data socket
listen socket_file, :backlog => 1024
pid pid_file

stderr_path log_file
stdout_path log_file

preload_app true

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  if File.exists?(old_pid) && server.pid != old_pid
    pid = File.read(old_pid).to_i
    begin
      Process.kill(:QUIT, pid)
      #Process.wait
    rescue Errno::ECHILD, Errno::ESRCH => e
      $stderr.puts ">> Process #{pid} has stopped"
    rescue Errno::ENOENT => e
      $stderr.puts ">> Error killing previous instance. #{e.message}"
      # someone else did our job for us
    end
  end
end


after_fork do |server, worker|
  begin
    uid, gid = Process.euid, Process.egid

    target_uid = File.stat(rack_root).uid
    user = Etc.getpwuid(target_uid).name

    target_gid = File.stat(rack_root).gid
    group = Etc.getgrgid(target_gid).name

    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    STDERR.puts "cannot change privileges on #{rack_env} environment"
    STDERR.puts "  #{e}"
  end
end
