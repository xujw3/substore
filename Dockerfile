# 直接使用 xream/sub-store 官方镜像
FROM xream/sub-store:2.20.68-http-meta

# 安装必要工具
RUN apk add --no-cache curl unzip

# 创建所需目录结构
RUN mkdir -p /opt/app/data

# 下载 GeoLite 数据库文件
ADD https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb /opt/app/data/GeoLite2-Country.mmdb
ADD https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb /opt/app/data/GeoLite2-ASN.mmdb

# 设置正确的权限
RUN chmod -R 755 /opt/app

EXPOSE 3000

