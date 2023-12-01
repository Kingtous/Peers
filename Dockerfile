# 使用Flutter镜像作为基础镜像
FROM growerp/flutter-sdk-image:3.13.2 AS builder

# 设置工作目录
WORKDIR /app

# 拷贝项目文件到工作目录
COPY . .

# 获取Flutter依赖并构建Flutter Web项目
RUN flutter pub get
RUN flutter build web

# 使用Nginx镜像作为新的基础镜像
FROM nginx:alpine

# 复制Flutter Web构建结果到Nginx的默认静态文件目录
COPY --from=builder /app/build/web /usr/share/nginx/html

# 复制Nginx配置文件到Nginx配置目录
COPY nginx.conf /etc/nginx/nginx.conf

# 暴露端口80
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
