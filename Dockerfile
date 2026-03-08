# Stage 1: Build
FROM node:22-alpine AS builder
WORKDIR /app

# --- BAGIAN KRUSIAL: Menangkap ARG dari GitHub Actions ---
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_API_URL_ROOT
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL_ROOT=$NEXT_PUBLIC_API_URL_ROOT

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

COPY . .

# Sekarang Next.js bisa "melihat" URL API saat melakukan build
RUN pnpm build

# Stage 2: Production
FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
