require 'fileutils'
require 'digest/md5'
require 'time'

git_base_url = "https://github.com"

# Git 仓库名
repo_names = [
  "QiuChenlyOpenSource/91QiuChen",
  "yuzu-mirror/yuzu",
  "suyu-emu/suyu"
]

# Git仓库的URL数组
repo_urls = repo_names.map { |repo_name| "#{git_base_url}/#{repo_name}.git" }

# 最多备份个数
max_backup_count = 10

# 备份目录路径
backup_dir = "./backup"
# 备份分支路径
backup_branch_dir = "./backup_branch"
# 开发模式标志
dev_mode = false

# 如果备份分支目录不存在，警告退出
unless File.directory?(backup_branch_dir)
  puts "[E] Backup branch directory #{backup_branch_dir} not found"
  puts "Ruby script aborted."
  exit
end

# 如果备份目录不存在，创建它
unless File.directory?(backup_dir)  
  FileUtils.mkdir_p(backup_dir)
end

# 遍历所有的仓库URL
repo_urls.each do |repo_url|
  # 生成备份的目录名（基于当前时间和仓库名的md5）
  # repo_name = repo_url.split("/").last.gsub(".git", "")
  repo_name = repo_url.split("/").last.gsub(".git", "")
  repo_name_md5 = Digest::MD5.hexdigest(repo_name)
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")
  backup_repo_dir = File.join(backup_dir, repo_name_md5, "#{timestamp}")
  # 如果不是开发模式，执行git clone命令
  if dev_mode
    puts "Current directory: #{Dir.pwd}"
    puts "Would execute: git clone #{repo_url} #{backup_repo_dir} --depth 1"
    puts "Glob path: #{File.join(backup_branch_dir, repo_name_md5, "*")}"
    puts "Backup file: #{Dir.glob(File.join(backup_branch_dir, repo_name_md5, "*"))}"
  else
    `git clone #{repo_url} #{backup_repo_dir} --depth 1`
    puts "Backup of #{repo_url} taken in #{backup_repo_dir}"
    # 获取最近一次备份仓库的时间（找文件）
    last_backup_file = Dir.glob(File.join(backup_branch_dir, repo_name_md5, "*")).sort.last
    if last_backup_file.nil?
      last_backup_time = Time.at(0)
    else
      last_backup_time = File.mtime(last_backup_file)
    end
    puts "Last backup time: #{last_backup_time}" # 2024-03-09 16:16:49 +0000
    # 检查最近一次 commit 的时间
    last_commit_time = `cd #{backup_repo_dir} && git log -1 --format=%cd`.chomp
    puts "Last commit time: #{last_commit_time}" # Sun Mar 10 00:16:28 2024 +0800
    # 转换全部时间格式
    last_commit_time = Time.parse(last_commit_time)
    puts "Last commit time (parse): #{last_commit_time}" # 2024-03-09 16:16:49 +0000
    last_backup_time = Time.parse(last_backup_time.to_s)
    puts "Last backup time (parse): #{last_backup_time}" # 2024-03-09 16:16:49 +0000
    # 减少备份的次数：如果最后一次 commit 之后有备份，就取消这次备份
    if last_commit_time <= last_backup_time
      puts "<<< No new commits since last backup. No need to backup"
      FileUtils.rm_rf(backup_repo_dir)
      puts "Backup of #{repo_url} removed. No new commits since last backup"
      next
    end
    puts ">>> New commits since last backup. Backup needed"
    # 删除 .git 目录
    FileUtils.rm_rf(File.join(backup_repo_dir, ".git"))
    puts "Removed .git directory from #{backup_repo_dir}"
    # 如果备份成功，将备份的目录压缩为zip文件
    if File.directory?(backup_repo_dir)
      backup_zip_file = "#{backup_repo_dir}.zip"
      `zip -r #{backup_zip_file} #{backup_repo_dir}`
      puts "Backup of #{repo_url} zipped to #{backup_zip_file}"
    end
    # 如果压缩成功，删除备份的目录
    if File.exist?(backup_zip_file)
      FileUtils.rm_rf(backup_repo_dir)
      puts "Backup of #{repo_url} removed"
    end
    # 检查备份个数，如果超过 max_backup_count 个，删除最早的一个
    backup_files = Dir.glob(File.join(backup_dir, "#{repo_name_md5}_*"))
    if backup_files.length > max_backup_count
      oldest_backup_file = backup_files.sort.first
      FileUtils.rm_rf(oldest_backup_file)
      puts "Oldest backup #{oldest_backup_file} removed"
    end
  end
end
