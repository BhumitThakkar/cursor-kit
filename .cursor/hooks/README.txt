Cursor lifecycle hooks (beta) are configured in the PARENT file: ../hooks.json
Add hook entries there that run commands at events like beforeSubmitPrompt, afterFileEdit, stop.
Put scripts you invoke from hooks.json in this folder (or elsewhere); use paths relative to the repo root as required by your Cursor version.
Docs: https://cursor.com/docs/hooks

NOTE: This repo ships hooks.json with an empty "hooks" object on purpose. Your user profile may already define many hooks under %USERPROFILE%\.cursor\hooks.json — those are global and are NOT duplicated here unless you copy them in for team sharing.
