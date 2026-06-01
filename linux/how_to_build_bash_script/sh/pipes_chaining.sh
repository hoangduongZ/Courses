#!/usr/bin/env bash
# Bash
# Pipe
cat file.txt | grep "error" | wc -l

# Chaining
mkdir backup && cp *.txt backup/

# Fallback
cp file.txt backup/ || echo "Copy failed"

# Background job
long_process.sh &