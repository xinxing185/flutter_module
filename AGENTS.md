## Git workflow

Before making any code changes:

1. Update main branch
   git fetch origin
   git checkout main
   git pull origin main --ff-only

2. Create a feature branch
   git checkout -b codex/${task}

3. Implement the change