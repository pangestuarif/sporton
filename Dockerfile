# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# WAJIB ADA: Agar build-arg dari GitHub Actions bisa masuk
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_API_URL_ROOT

# WAJIB ADA: Agar Next.js "membakar" variabel ini saat proses build
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL_ROOT=$NEXT_PUBLIC_API_URL_ROOT

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

COPY . .

# Proses ini akan menggunakan variabel di atas
RUN pnpm build

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

# Set port agar server.js berjalan di port 80 (Menghilangkan 502 Bad Gateway)
ENV PORT=80
ENV NODE_ENV=production

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 80

CMD ["node", "server.js"]
