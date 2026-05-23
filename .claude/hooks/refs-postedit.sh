#!/usr/bin/env bash
# PostToolUse hook for the kusara cross-reference graph.
#
# Claude Code sends the hook payload as JSON over stdin. We extract
# tool_input.file_path and tool_name, dispatch to kusara, detect
# judgment-needed triggers, and surface results via
# hookSpecificOutput.additionalContext.
#
# Mechanical checks:
#   *.md edits                              -> kusara validate
#   packages/*/lib|test + docs/kinds.md     -> kusara touched <file>
#
# The hook never exits non-zero -- it is purely informational.

set -u

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

payload="$(cat)"
[[ -z "$payload" ]] && exit 0

abs_path=""
tool_name=""
if command -v jq >/dev/null 2>&1; then
  abs_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
  tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"
elif command -v python3 >/dev/null 2>&1; then
  abs_path="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print((d.get("tool_input") or {}).get("file_path", "") or "")
except Exception:
    pass')"
  tool_name="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_name", "") or "")
except Exception:
    pass')"
else
  exit 0
fi
[[ -z "$abs_path" ]] && exit 0

file="${abs_path#"$PWD/"}"
[[ -z "$file" ]] && exit 0

if command -v kusara >/dev/null 2>&1; then
  bin="$(command -v kusara)"
else
  if command -v jq >/dev/null 2>&1; then
    printf '%s' 'kusara binary not found on $PATH. Run /kusara:setup to install.' | jq -Rs '{
      hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: . }
    }'
  fi
  exit 0
fi

# --- mechanical check ---
out=""
case "$file" in
  *.md)
    out="$($bin validate 2>&1 || true)"
    if [[ "$out" =~ ^OK ]]; then
      out=""
    fi
    ;;
  packages/*/lib/*|packages/*/test/*|docs/kinds.md)
    out="$($bin touched "$file" 2>&1 || true)"
    ;;
esac

# --- judgment triggers ---
judgment=""

is_new_md=false
if [[ "$tool_name" == "Write" && "$file" == *.md ]]; then
  if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
    is_new_md=true
  fi
fi

# Trigger 1: new .md file.
if $is_new_md; then
    judgment+='
## Judgment: new `.md` file

Pick kind by matching the file path against `docs/kinds.md` `path_globs`:
- Path matches an existing kind glob -> add `refs:` of that kind, mirroring the closest sibling.
- New instance, new location -> extend the `path_globs` for that kind, then add `refs:`.
- New category -> add a new kind entry to `docs/kinds.md`, then add `refs:`.
- Outside graph (README/template/generated) -> no `refs:`; tighten the glob if validate complains.

Invoke the `kusara:refs-schema` skill for field reference. Do not guess fields.
'
fi

# Trigger 2: source change under packages/*.
case "$file" in
  packages/*/lib/*|packages/*/test/*)
    judgment+='
## Judgment: source change

Per the `touched` output above, decide which doc (if any) to update:

| Change | Doc update? |
|---|---|
| Internal (refactor / bugfix / perf / dep bump) | none |
| New / changed user-facing behavior | relevant `fr:NN-*` |
| New / changed system design (state flow, module boundary, pipeline) | relevant `arch:*` |
| New / changed preset config consumption contract | `integration:preset` |
| New / changed package public surface | relevant `pkg:*` |

If unsure whether a change is "public surface", err on updating the doc.
'
    ;;
esac

# Trigger 3: docs/kinds.md edit.
if [[ "$file" == "docs/kinds.md" ]]; then
  judgment+='
## Judgment: kinds.md edit

| Edit type | Risk |
|---|---|
| Tightening a `path_globs` | safe |
| Loosening / adding new globs | every newly-matched file must have `refs:` (validator enforces) |
| Renaming a kind | invalidates every `kind: <old-name>` in existing front matter; audit + rewrite |
| Adding `index.output` | run `kusara index` once to materialize the file |
'
fi

# Trigger 4: existing graph-linked .md edit -> surface links for body sync.
if ! $is_new_md && [[ "$file" == *.md && -f "$file" ]]; then
  doc_id="$(awk '
    /^---$/{f++; if(f>=2)exit; next}
    f==1 && /^[[:space:]]+id:[[:space:]]+/{
      sub(/^[[:space:]]+id:[[:space:]]+/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$file")"

  if [[ -n "$doc_id" ]]; then
    show_out="$($bin show "$doc_id" 2>&1 || true)"
    if [[ -n "$show_out" ]]; then
      judgment+='
## Judgment: linked-doc content drift

If this edit changed observable behavior (not a typo or prose-only tweak), the linked docs below may need matching content updates. Re-read each before deciding to update.

```
'"$show_out"'
```
'
    fi
  fi
fi

# --- combine and emit ---
final=""
[[ -n "$out" ]] && final="$out"
if [[ -n "$judgment" ]]; then
  if [[ -n "$final" ]]; then
    final="${final}
${judgment}"
  else
    final="$judgment"
  fi
fi

[[ -z "$final" ]] && exit 0

final="${final}
---
Authoritative rule: \`.claude/rules/project/refs.md\`. Schema: invoke the \`kusara:refs-schema\` and \`kusara:kinds-manifest\` skills."

if command -v jq >/dev/null 2>&1; then
  printf '%s' "$final" | jq -Rs '{
    hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: . }
  }'
elif command -v python3 >/dev/null 2>&1; then
  printf '%s' "$final" | python3 -c '
import json, sys
ctx = sys.stdin.read()
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": ctx,
    }
}))'
else
  printf '%s\n' "$final" >&2
fi

exit 0
