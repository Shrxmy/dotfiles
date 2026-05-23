---
description: Generate a commit message based on recent git changes
argument-hint: [type]
---

Generate a concise, conventional commit message based on the current git changes.

Steps:
1. Run `git status` to see what files have changed
2. Run `git diff --staged` to see staged changes, or `git diff` for unstaged
3. Analyze the changes and generate a commit message following conventional commits format:
   - `feat:` new feature
   - `fix:` bug fix
   - `docs:` documentation changes
   - `style:` code style (formatting, no logic change)
   - `refactor:` code refactoring
   - `test:` adding/updating tests
   - `chore:` maintenance, deps, build changes

4. Output format:
```
<type>: <short description>

- <change 1>
- <change 2>
- <change 3>
```

Keep the description under 72 characters. List具体的 changes as bullet points.

If there are no changes, output "No changes to commit."

Example output:
```
feat: Add user authentication flow

- Implement login/logout handlers
- Add JWT token generation
- Create auth middleware
```