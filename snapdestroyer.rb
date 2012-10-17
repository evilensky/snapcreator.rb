#!/usr/bin/env ruby

## For cleaning up snaps and 


require 'fileutils.rb'

#constants
backup_path = "/mnt/orabackup/"
vg = "vgRoot"
lv = "lvRoot"
backup_date = ""

#return epic fail if more than one lock file
def test_lock (backup_path)
  flock_dir = Dir.entries(backup_path)
  flock_dir.count { |x| x.include? "flock"}
end




if test_lock(backup_path) != 1
	abort("Abort!  More or less than one lockfile found.")
end

#remove ./current symlink
if File.symlink?("#{backup_path}/current")
  puts backup_date = /[0-9]+/.match(File.readlink("#{backup_path}/current"))
  `umount #{backup_path}/#{backup_date}`
  File.unlink("#{backup_path}/current")
  Dir.rmdir("#{backup_path}/#{backup_date}")
puts  `lvremove -f /dev/#{vg}/#{lv}-#{backup_date}`
  File.unlink("#{backup_path}/#{backup_date}.flock")
end