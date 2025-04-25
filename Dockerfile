# 直接使用 xream/sub-store 官方镜像
FROM xream/sub-store:latest

# 如果需要，可以添加额外的配置或文件
# 例如，如果需要自定义配置文件：
# COPY ./my-config.json /app/config.json

# 端口已在基础镜像中暴露，前后端运行在同一端口
EXPOSE 3000

