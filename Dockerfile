FROM nginx
RUN echo "<h1>Hello World</h1>" > /some/content:/usr/share/nginx/html/index.html
