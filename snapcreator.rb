#!/usr/bin/env ruby


#For taking LVM snaps and mounting them

require 'fileutils.rb'

#constants
backup_path = "/mnt/orabackup/"
backup_date = Time.now.strftime("%Y%m%d%H%M")
snap_size   = "500Mib"
vg = "vgRoot"
lv = "lvRoot"

#return false if you find the lockfile
def test_lock (backup_path)
  Dir.foreach(backup_path) do |f|
    if f.include?("flock") then
       puts "Error! #{f} exists!"
       return true
    end
  end
  return false
end

#create the backup folder and its lockfile
def create_folder_lock (backup_path, backup_date)
  #create backup time directory
  FileUtils.mkdir_p "#{backup_path}#{backup_date}"
  #create backup time lockfile
  lockfile = File.new("#{backup_path}" + "#{backup_date}.flock", "w+").flock(File::LOCK_EX)
end

def shutdown_service (service)
  puts "Stopping #{service}"
  puts `/etc/init.d/#{service} stop`
end

def startup_service (service)
  puts "Starting #{service}"
  puts `/etc/init.d/#{service} start`
end


def take_snapshot(size, vg, lv, backup_date)
  `lvcreate -L #{size} -s -n #{lv}-#{backup_date} /dev/#{vg}/#{lv}`
end

def mount_snapshot(vg, lv, backup_date, backup_path)
  `mount /dev/#{vg}/#{lv}-#{backup_date} #{backup_path}#{backup_date}`
end



def go(size, vg, lv, backup_date, backup_path)
  if test_lock(backup_path) == false
    create_folder_lock(backup_path, backup_date)
    shutdown_service("httpd")
    take_snapshot(size, vg, lv, backup_date)
    mount_snapshot(vg, lv, backup_date, backup_path)
  else
      puts "aborted due to lock file(s)"
  end
end

go(snap_size, vg, lv, backup_date, backup_path)
