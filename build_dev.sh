# amd64
docker build -f Dockerfile.alpine --no-cache --progress=plain -t activeliang/wgcf-socks5-proxy --platform linux/amd64 --build-arg HTTP_PROXY=http://host.docker.internal:7890 --build-arg https_proxy=http://host.docker.internal:7890 .
# docker build -f Dockerfile -t activeliang/wgcf-socks5-proxy --platform linux/amd64 --build-arg HTTP_PROXY=http://host.docker.internal:7890 --build-arg https_proxy=http://host.docker.internal:7890 .

# arm64 
docker build -f Dockerfile.alpine --no-cache --progress=plain -t activeliang/wgcf-socks5-proxy:arm64 --platform linux/arm64 --build-arg HTTP_PROXY=http://host.docker.internal:7890 --build-arg https_proxy=http://host.docker.internal:7890 .
# docker build -f Dockerfile -t activeliang/wgcf-socks5-proxy --platform linux/arm64 --build-arg HTTP_PROXY=http://host.docker.internal:7890 --build-arg https_proxy=http://host.docker.internal:7890 .

# 打包同时支持amd64和arm64
docker buildx build --platform linux/amd64,linux/arm64 -t activeliang/wgcf-socks5-proxy -f Dockerfile.alpine --push .


docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    -p 7889:1080 \
    activeliang/wgcf-socks5-proxy -6

docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker:alpine  sh