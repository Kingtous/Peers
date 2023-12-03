FROM bitnami/git:latest as builder
LABEL maintainer="kingtous"

WORKDIR /app

COPY ./.git .
RUN git config core.worktree .
RUN git checkout gh-pages

# 使用Nginx镜像作为新的基础镜像
FROM nginx:alpine

# 复制Flutter Web构建结果到Nginx的默认静态文件目录
COPY --from=builder /app/ /usr/share/nginx/html

# 复制Nginx配置文件到Nginx配置目录
# COPY nginx.conf /etc/nginx/nginx.conf

# 暴露端口80
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
