# masscantainer
Simple container for running [masscan](https://github.com/robertdavidgraham/masscan). As you know, masscan is a mass IP port scanner.

## use
There should be a built image in docker hub called `jdimpson/masscan` before anyone reads this.

## build
Pulls in latest version of [masscan](https://github.com/robertdavidgraham/masscan) and creates a runnable image.
```
git clone https://github.com/jdimpson/masscantainer
cd masscantainer
./build.sh
```
## run

You can pass any of [masscan's command line arguments](https://github.com/robertdavidgraham/masscan#usage) to this container.

You can run the `docker-masscan.sh` script, or just execute a `docker run` command directly. You do need to think about your network configuration, however. Here are your options, but note that I've done absolutely ZERO benchmarking.

### network option 1
`docker run -it --rm jdimpson/masscan <masscan args>`

This uses default docker NAT networking, which probably means a significant slowdown compared to what masscan is capable of on baremetal server, as it gets processed by the host's `iptables` code. Benefit is it won't mess with any of the host's other network connections. This is good because `masscan`'s `--src-ip` flag doesn't work in this configuration.

### network option 2
`docker run -it --rm --net=host jdimpson/masscan <masscan args>`

This uses the host's network interface directly, and should *in theory* provide the same performance as masscan on baremetal can do. Also *in theory* it will use the [PF_RING capability](https://github.com/robertdavidgraham/masscan#pf_ring) of the docker host's network interface, if it exists.

However, it will use the IP address of the host server, which as documented [here](https://github.com/robertdavidgraham/masscan#masscan-mass-ip-port-scanner) potentially will mess with network connections on the host. Use with caution and/or wreckless abandon. (The `docker-masscan.sh` script uses this, as I like to live dangerously.)

Fortunately, the `--src-ip` flag does work in this configuration, but you also need to provide the `--router-mac 66-55-44-33-22-11` argument as well, and I'm not sure why. There is more going on in this network mode than I realize.

### network option 3
`docker run -it --rm --net=macvlan0 jdimpson/masscan <masscan args>`

This uses a macvlan called `macvlan0` which you have to [create](https://docs.docker.com/network/drivers/macvlan/) on the docker host. Using it should be faster than using option 1 (docker NAT) but may not be as fast as option 2 (docker host's interface). (Because it has to go through the macvlan code in addition to the raw network interface it usually goes through.) But like option 1 it will not mess with other network connections on the docker host.

Again, the `--src-ip` flag works, but if you've gone to the trouble of setting up a macvlan network for the container, you don't need to change the src ip, because the macvlan interface and IP address are wholly dedicated to the container. Again, also mysteriously, the `--router-mac 66-55-44-33-22-11` argument is needed in this mode. I guess it's becasue macvlans are not really software bridges, but exactly what's different, I do not know.
