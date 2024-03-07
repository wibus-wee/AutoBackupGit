# 项目备份工具

这是一个使用 Ruby 编写的项目备份工具。它可以将指定的 Git 仓库克隆到本地，并将其压缩为 zip 文件。

## 文件结构

- `main.rb`: 这是主要的脚本文件，包含了备份操作的所有逻辑。
- `.github/workflows/backup.yml`: 这是一个 GitHub Actions 工作流文件，它配置了一个定时任务，每天在 UTC 时间 12:00 执行备份操作。

## 使用方法

1. 在 `main.rb` 文件中，将 `repo_urls` 数组修改为你想要备份的 Git 仓库的 URL。
2. 运行 `main.rb` 脚本，它会将每个仓库克隆到 `backup` 目录，并将其压缩为 zip 文件。

## GitHub Actions 自动备份

你可以使用 GitHub Actions 来自动执行备份操作。只需将此仓库推送到你的 GitHub 账户，然后在 `Settings` -> `Secrets` 中添加你的 Git 仓库 URL。然后，GitHub Actions 就会每天在 UTC 时间 12:00 执行备份操作，并将备份文件推送到 `backup` 分支。

注意：在 `backup.yml` 文件中，你可能需要修改 `branch` 参数，以匹配你的备份分支名称。

## 开发模式

在 `main.rb` 文件中，你可以设置 `dev_mode` 为 `true`，这样脚本在执行 `git clone` 命令时，只会打印命令，而不会真正执行。这对于测试和调试非常有用。

## MD5 Directory Name

```shell
md5 -s 91QiuChen
md5 -s yuzu
```