kill port
lsof -ti:8080 | xargs kill -9 2>/dev/null; echo "Killed processes on port 8080"