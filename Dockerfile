# 使用官方 CentOS 7 基础镜像
FROM centos:7

# 设置腾讯云镜像源和 EPEL 源
RUN yum install -y wget && \
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo && \
    yum makecache

# 导入 MySQL 公钥
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# 安装必要的软件包和依赖
RUN yum -y update && \
    yum -y install perl libaio numactl net-tools vim

# 下载 MySQL 5.7 的 Yum Repository 配置文件
RUN wget https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm && \
    rpm -ivh mysql57-community-release-el7-11.noarch.rpm && \
    yum -y update

# 安装 MySQL 5.7
RUN yum -y install mysql-community-server-5.7.35

# 创建 mysql 用户组和用户
RUN getent group mysql || groupadd -r mysql && \
    useradd -r -g mysql mysql

# 配置 MySQL
RUN mkdir -p /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chmod 777 /var/lib/mysql && \
    sed -i 's/^# character-set-server=utf8mb4/character-set-server=utf8mb4/g' /etc/my.cnf && \
    sed -i 's/^# collation-server=utf8mb4_general_ci/collation-server=utf8mb4_general_ci/g' /etc/my.cnf && \
    echo "[mysqld]\nbind-address=0.0.0.0\n" >> /etc/my.cnf && \
    echo "skip-host-cache\nskip-name-resolve\n" >> /etc/my.cnf && \
    echo "default-storage-engine = innodb\ninnodb_file_per_table = 1\ninnodb_flush_log_at_trx_commit = 2\nsync_binlog = 0\n" >> /etc/my.cnf && \
    echo "user = mysql\n" >> /etc/my.cnf && \
    echo "skip-networking=0\n" >> /etc/my.cnf && \
    echo "skip-grant-tables\n" >> /etc/my.cnf

# 设置启动命令
CMD ["mysqld", "--user=mysql"]
