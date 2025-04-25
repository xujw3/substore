FROM alpine:latest

WORKDIR /opt/app

# 设置时区并保留 tzdata 以保证时区功能正常
ENV TIME_ZONE=Asia/Shanghai
RUN apk add --no-cache nodejs curl tzdata unzip \
    && cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime \
    && echo $TIME_ZONE > /etc/timezone

# 预先创建数据目录以便一次性设置权限
RUN mkdir -p /opt/app/data

# 在一个层中下载所有需要的文件以减少镜像大小
RUN curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/sub-store.bundle.js https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/dist.zip https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip \
    && unzip /opt/app/dist.zip -d /opt/app \
    && mv /opt/app/dist /opt/app/frontend \
    && rm /opt/app/dist.zip \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/http-meta.bundle.js https://github.com/xream/http-meta/releases/latest/download/http-meta.bundle.js \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/data/tpl.yaml https://github.com/xream/http-meta/releases/latest/download/tpl.yaml \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/data/GeoLite2-Country.mmdb https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
    -o /opt/app/data/GeoLite2-ASN.mmdb https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb

# 在单独的层中下载并解压 mihomo 以便更好地缓存
RUN version=$(curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 \
        'https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt') \
    && arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64-compatible/) \
    && url="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-$arch-$version.gz" \
    && curl -s -L --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 2 "$url" -o /opt/app/data/http-meta.gz \
    && gunzip /opt/app/data/http-meta.gz \
    && chmod +x /opt/app/data/http-meta

# 设置权限并清理
RUN chmod 755 -R /opt/app \
    && apk del unzip \
    && rm -rf /var/cache/apk/*

# 设置运行时配置的环境变量 - 修复了可能导致错误的环境变量配置
ENV SUB_STORE_BACKEND_API_HOST=:: \
    SUB_STORE_FRONTEND_HOST=:: \
    SUB_STORE_FRONTEND_PORT=3000 \
    SUB_STORE_BACKEND_MERGE=true \
    SUB_STORE_FRONTEND_BACKEND_PATH="/" \
    SUB_STORE_FRONTEND_PATH=/opt/app/frontend \
    SUB_STORE_DATA_BASE_PATH=/opt/app/data \
    SUB_STORE_MMDB_COUNTRY_PATH=/opt/app/data/GeoLite2-Country.mmdb \
    SUB_STORE_MMDB_ASN_PATH=/opt/app/data/GeoLite2-ASN.mmdb \
    META_FOLDER=/opt/app/data \
    HOST=:: \
    PORT=9876

# 创建启动脚本
COPY --chmod=755 <<'EOF' /opt/app/entrypoint.sh
#!/bin/sh
cd /opt/app/data
node /opt/app/http-meta.bundle.js > /opt/app/data/http-meta.log 2>&1 &
echo "HTTP-META is running..."
exec node /opt/app/sub-store.bundle.js
EOF

ENTRYPOINT ["/opt/app/entrypoint.sh"]

# 暴露端口
EXPOSE 3000
