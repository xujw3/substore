# 基于官方 Node.js 镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 安装git和必要的构建工具
RUN apk add --no-cache git curl bash

# 克隆 Sub-Store 仓库
RUN git clone https://github.com/sub-store-org/Sub-Store.git .

# 安装后端依赖并构建
WORKDIR /app/backend
RUN npm install

# 安装前端依赖并构建
WORKDIR /app/frontend
RUN npm install && \
    npm run build

# 将前端构建产物复制到后端的public目录
RUN mkdir -p /app/backend/public && \
    cp -r dist/* /app/backend/public/

# 设置工作目录回到后端
WORKDIR /app/backend

# 设置环境变量
ENV PORT=3000
ENV HOST=0.0.0.0
ENV SERVE_STATIC=true
ENV STATIC_PATH=/app/backend/public

# 暴露端口
EXPOSE 3000

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 运行应用
CMD ["npm", "start"]

# 添加元数据
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Sub-Store - A subscription manager with frontend and backend on the same port"
LABEL version="1.0"
