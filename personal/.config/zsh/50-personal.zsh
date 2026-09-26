# Personal machines only (stowed by the `personal` package — never on work).

# GitHub Copilot CLI → OpenTelemetry collector on localhost:4318.
# WARNING: captures prompts, responses, code, and tool inputs/outputs, and the
# OTEL_* names are generic — any OpenTelemetry-instrumented program sees them.
export COPILOT_OTEL_ENABLED="true"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
export OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT="true"

# --- Media ---
if (( $+commands[yt-dlp] )); then
  alias youtube-dl='yt-dlp --remux-video mp4'
  alias ytdl='yt-dlp --remux-video mp4 --force-generic-extractor'
fi

# --- WireGuard NAT-PMP port forwarding (natpmp-client.py comes from py-natpmp, pipx-tools.txt) ---
if (( $+commands[natpmp-client.py] )); then
  alias pf='while true; do date && natpmp-client.py -g 10.2.0.1 -u -l 60 0 0 && natpmp-client.py -g 10.2.0.1 -l 60 0 0 | grep port || { echo -e "ERROR with natpmpc command \a"; break; }; sleep 45; done'
fi
