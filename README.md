---
title: AWAS - Notifikasi Sampah & Gas
emoji: 🗑️
colorFrom: red
colorTo: yellow
sdk: docker
app_port: 5678
---

# AWAS - Notifikasi Sampah & Gas

n8n workflow untuk memantau tempat sampah dan gas berbahaya, dengan notifikasi otomatis ke Telegram.

## Cara Deploy

### Opsi 1: Hugging Face Spaces

1. Fork repo ini
2. Buat Space baru di Hugging Face → pilih **Docker** sebagai SDK
3. Hubungkan repo GitHub ke Space
4. Set environment variables di Settings Space

### Opsi 2: Railway / Render / Fly.io

1. Clone repo
2. Deploy langsung dari GitHub

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Token bot Telegram untuk notifikasi |

## Alur Workflow

1. **Webhook** → Menerima data dari sensor (ESP32)
2. **IF conditions** → Cek status sampah & gas
3. **Format Pesan** → Generate pesan notifikasi
4. **Kirim Telegram** → Kirim notifikasi ke chat Telegram

### Kondisi Notifikasi:
- 🚨 **DARURAT** → Sampah PENUH + Gas BERBAHAYA
- 🗑️ **Sampah Penuh** → Hanya sampah penuh
- ⚠️ **Gas Berbahaya** → Hanya gas berbahaya
