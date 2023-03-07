# 使用官方 CentOS 7 基础镜像
FROM centos:7

# 设置腾讯云镜像源和 EPEL 源
RUN yum install -y wget && \
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo && \
wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
    yum makecache

# 导入 MySQL 公钥
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql

# 安装必要的软件包和依赖
RUN yum -y update && \
    yum -y install perl libaio numactl net-tools vim

# 下载 MySQL 5.7 的 Yum Repository 配置文件
RUN wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# 安装 MySQL 5.7
RUN rpm -ivh mysql57-community-release-el7-11.noarch.rpm && \
    yum -y update && \
    yum -y install mysql-community-server

# 配置 MySQL
RUN mkdir /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chmod 777 /var/lib/mysql && \
    echo "[mysqld]\nbind-address=0.0.0.0\n" >> /etc/my.cnf && \
    echo "skip-host-cache\nskip-name-resolve\n" >> /etc/my.cnf && \
    echo "default-storage-engine = innodb\ninnodb_file_per_table = 1\ninnodb_flush_log_at_trx_commit = 2\nsync_binlog = 0\n" >> /etc/my.cnf && \
    echo "character-set-server=utf8mb4\ncollation-server=utf8mb4_unicode_ci\n" >> /etc/my.cnf && \
    echo "skip-networking=0\n" >> /etc/my.cnf && \
    echo "skip-grant-tables\n" >> /etc/my.cnf

# 设置启动命令
CMD ["mysqld_safe", "--init-file=/tmp/mysql-init.sql"]

# 密码初始化文件
COPY mysql-init.sql /tmp/
RUN chmod 644 /tmp/mysql-init.sql
