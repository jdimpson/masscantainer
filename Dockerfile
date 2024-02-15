FROM alpine:latest AS build
WORKDIR /src
RUN apk add git make gcc libc-dev linux-headers
RUN git clone https://github.com/robertdavidgraham/masscan.git
RUN cd masscan && make


FROM alpine:latest AS run
COPY --from=build /src/masscan/bin/masscan /masscan
RUN apk add curl iptables speedtest-cli libpcap
ENTRYPOINT ["/masscan"]
