#!/bin/bash

# 设置Git全局配置
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# 配置ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 配置ssh私钥
if [ -n "$SSH_PRIVATE_KEY" ]; then
    # 写入私钥
    echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    
    # 添加GitHub到已知主机
    ssh-keyscan github.com >> ~/.ssh/known_hosts
fi

# 初始化Git仓库
if [ -n "$GIT_REMOTE_URL" ]; then
    # 如果目录不是Git仓库，则初始化
    if [ ! -d .git ]; then
        git init
	GIT_SSH_URL=$(echo "$GIT_REMOTE_URL" | sed 's#https://github.com/#git@github.com:#')
        git remote add origin "$GIT_SSH_URL"
    fi
fi

# 运行Python脚本
exec python main.py \
    --db_user "$DB_USER" \
    --db_password "$DB_PASSWORD" \
    --db_host "$DB_HOST" \
    --db_port "$DB_PORT" \
    --db_name "$DB_NAME" \
    --sql_dir "$SQL_DIR" \
    --git_repo_path "$GIT_REPO_PATH" \
    --git_remote "$GIT_REMOTE" \
    --git_branch "$GIT_BRANCH" \
    --interval "$INTERVAL"
