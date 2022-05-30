#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

if [[ $# -eq 0 ]]; then
    echo "Missing topic argument!"
    echo "Usage: $0 <topic>"
    exit 1
fi

DATE=$(date +%F)
TOPIC="$1"
FILENAME="$DATE-$TOPIC.md"
if [[ -f "$FILENAME" ]]; then
    echo "File already exists. Exiting..."
    exit 1
fi

cat > "./$FILENAME" <<EOF
---
date: "$(date --iso-8601=seconds)"
---

# $TOPIC
EOF

exec vim "./$FILENAME"
