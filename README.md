# wgcf-docker

CloudFlare warp in docker

fork from: https://github.com/Neilpang/wgcf-docker

#### What improvements did I make:

1. Limit the alpine version to 3.17 to avoid errors caused by version issues.
2. Added socks5 proxy service

Run example:

```shell
docker run --rm -it \
     --name wgcf \
     --sysctl net.ipv6.conf.all.disable_ipv6=0 \
     --privileged --cap-add net_admin \
     -v /lib/modules:/lib/modules \
     -v $(pwd)/wgcf:/wgcf \
     -p 7889:1080 \
     activeliang/wgcf-socks5-proxy -6
```

Now you can use the socks proxy on the host machine:

```shell
curl --socks5 127.0.0.1:7889 -6 ip.p3terx.com
```

## Configurable SOCKS5 Proxy with Environment Variables

This SOCKS5 proxy supports configuration through environment variables. You can customize the proxy settings using the following variables: USER, PASSWORD, PORT, and HOST. Authentication (auth) will only be enabled if both the USER and PASSWORD variables are provided.

### Usage

To configure the SOCKS5 proxy, follow these steps:

1. Set the following environment variables:

   - USER: The username for authentication (optional).
   - PASSWORD: The password for authentication (optional).
   - PORT: The port number for the proxy server (default: 1080).
   - HOST: The host address for the proxy server (default: 0.0.0.0).

   Note: Authentication will be enabled only if both the USER and PASSWORD variables are provided. If either one is missing, authentication will not be enabled.

2. Start the SOCKS5 proxy using your preferred method, passing the environment variables as arguments.

   Example:

   ```bash
    PASSWORD=mypassword PORT=1080 HOST=0.0.0.0 start_proxy.sh
   docker run --rm -it \
     --name wgcf \
     --sysctl net.ipv6.conf.all.disable_ipv6=0 \
     --privileged --cap-add net_admin \
     -v /lib/modules:/lib/modules \
     -v $(pwd)/wgcf:/wgcf \
     -p 7889:1080 \
     -e USER=myuser \
     -e PASSWORD=mypassword \
     -e PORT=1080 \
     -e HOST=0.0.0.0 \
     activeliang/wgcf-socks5-proxy -6
   ```

   This command will start the SOCKS5 proxy with the specified configuration.

3. The SOCKS5 proxy will be accessible on the specified host and port. Authentication will be enforced only if both the USER and PASSWORD variables are provided.

That's it! You can now configure the SOCKS5 proxy using environment variables, with the option to enable authentication by providing both the USER and PASSWORD variables.


## The following is the readme of the original project

1. Run a single container:

```

docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker



The above command will enable both ipv4 and ipv6, you can enable ipv4 or ipv6 only like following:


#enable ipv4 only:



docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker  -4 



#enable ipv6 only:



docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker  -6 



```

or:

```
docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker:alpine





The above command will enable both ipv4 and ipv6, you can enable ipv4 or ipv6 only like following:


#enable ipv4 only:


docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker:alpine  -4



#enable ipv6 only:


docker run --rm -it \
    --name wgcf \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --privileged --cap-add net_admin \
    -v /lib/modules:/lib/modules \
    -v $(pwd)/wgcf:/wgcf \
    neilpang/wgcf-docker:alpine  -6




```

2. If aonther container needs to use the wgcf network, run it like:

```

docker run --rm  -it  --network container:wgcf  curlimages/curl curl ipinfo.io

```

3. Docker-compose example:

```
Enable both ipv4 and ipv6 by default:


version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:latest
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipinfo.io




Enable ipv6 only:

version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:latest
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    command: "-6"
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipv6.ip.sb





Enable ipv4 only:



version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:latest
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    command: "-4"
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipinfo.io



```

or:

```

Enable both ipv4 and ipv6 by default:



version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:alpine
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipinfo.io

  
  





Enable ipv6 only:



version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:alpine
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    command: "-6"
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipv6.ip.sb






Enable ipv4 only:



version: "2.4"
services:
  wgcf:
    image: neilpang/wgcf-docker:alpine
    volumes:
      - ./wgcf:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    command: "-4"
  

  test:
    image: curlimages/curl
    network_mode: "service:wgcf"
    depends_on:
      - wgcf
    command: curl ipinfo.io





```
