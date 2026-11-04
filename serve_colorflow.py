import http.server
import socketserver

WEB_DIR = "/home/mathdev/.gemini/antigravity/scratch/colorflow-app/dist"

class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

socketserver.TCPServer.allow_reuse_address = True
print("Starting ColorFlow server on port 8086...")
with socketserver.TCPServer(("", 8086), NoCacheHandler) as httpd:
    httpd.serve_forever()
