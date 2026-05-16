FROM node:20-alpine
WORKDIR /app
COPY package.json ./
COPY server.js ./
EXPOSE 3000
ENV NODE_ENV=production
# Upstream IPTV servers refuse IPv6 connections (no AAAA / DC IPv6 blocks).
# Prefer IPv4 for outbound DNS so node:fetch doesn't pick a v6 address first.
CMD ["node", "--dns-result-order=ipv4first", "server.js"]
