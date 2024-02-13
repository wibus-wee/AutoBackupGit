require 'fileutils'
require 'digest/md5'

# Git仓库的URL数组
repo_urls = ["https://github.com/QiuChenlyOpenSource/91QiuChen.git"]
# 最多备份个数
max_backup_count = 10

# 备份目录路径
backup_dir = "./backup"

# 开发模式标志
dev_mode = false

# 如果备份目录不存在，创建它
unless File.directory?(backup_dir)  
  FileUtils.mkdir_p(backup_dir)
end

# 删除备份目录下的全部压缩文件
Dir.glob(File.join(backup_dir, "*.zip")).each do |file|
  FileUtils.rm_rf(file)
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
    puts "Would execute: git clone #{repo_url} #{backup_repo_dir} --depth 1"
  else
    `git clone #{repo_url} #{backup_repo_dir} --depth 1`
    puts "Backup of #{repo_url} taken in #{backup_repo_dir}"
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
