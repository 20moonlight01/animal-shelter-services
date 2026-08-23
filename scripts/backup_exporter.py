#!/usr/bin/env python3
import os
import re
import subprocess
import time
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler

BUCKET = os.environ.get("BUCKET_BACKUP_NAME")
MINIO_USER = os.environ.get("MINIO_BACKUP_USER")
MINIO_PASSWORD = os.environ.get("MINIO_BACKUP_PASSWORD")
PORT = int(os.environ.get("PORT", "8080"))

def parse_size(size_str):
    size_str = size_str.strip()
    units = {
        'B': 1,
        'KiB': 1024,
        'MiB': 1024 ** 2,
        'GiB': 1024 ** 3,
        'TiB': 1024 ** 4
    }
    match = re.match(r'([\d.]+)\s*([A-Za-z]+)', size_str)
    if match:
        value = float(match.group(1))
        unit = match.group(2)
        return int(value * units.get(unit, 1))
    return 0

def setup_mc():
    subprocess.run([
        "mc", "alias", "set", "myminio",
        "http://minio:9000", MINIO_USER, MINIO_PASSWORD
    ], check=True)

def get_last_backup():
    result = subprocess.run(["mc", "ls", f"myminio/{BUCKET}"], capture_output=True, text=True)
    lines = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]
    backups = []
    for line in lines:
        parts = line.split()
        if len(parts) >= 5:
            size_bytes = parse_size(parts[3])
            backups.append({"name": parts[5], "size": size_bytes})
    if not backups:
        return None
    backups.sort(key=lambda x: x["name"], reverse=True)
    return backups[0]

def parse_timestamp(name):
    match = re.search(r'backup_(\d{8}_\d{6})', name)
    if match:
        dt = datetime.strptime(match.group(1), "%Y%m%d_%H%M%S")
        return int(dt.timestamp())
    return None

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            last = get_last_backup()
            metrics = []
            if last:
                ts = parse_timestamp(last["name"])
                if ts:
                    metrics.append(f"backup_last_success_timestamp {ts}")
                metrics.append(f"backup_last_size_bytes {last['size']}")
                metrics.append(f"backup_exists 1")
            else:
                metrics.append(f"backup_exists 0")
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write("\n".join(metrics).encode())
        else:
            self.send_response(404)

if __name__ == "__main__":
    if not all([BUCKET, MINIO_USER, MINIO_PASSWORD]):
        print("ERROR: Missing required environment variables")
        exit(1)
    
    setup_mc()
    print(f"Backup exporter listening on port {PORT}")
    HTTPServer(('0.0.0.0', PORT), MetricsHandler).serve_forever()