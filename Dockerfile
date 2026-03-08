# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# ARG NEXT_PUBLIC_API_URL
# ARG NEXT_PUBLIC_API_URL_ROOT

# ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
# ENV NEXT_PUBLIC_API_URL_ROOT=$NEXT_PUBLIC_API_URL_ROOT

COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm && pnpm install

COPY . .

RUN pnpm build

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 80

# Tambahkan baris ini agar Next.js tahu harus jalan di port 80
ENV PORT 80
ENV HOSTNAME "0.0.0.0"

# API_URL_INTERNAL tetap bisa di-set runtime
ENV API_URL_INTERNAL=""
ENV API_URL_INTERNAL_ROOT=""

CMD ["node", "server.js"]
