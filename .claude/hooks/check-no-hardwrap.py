#!/usr/bin/env python3
"""PreToolUse hook: blocks gh pr/issue create|edit and gh api comment/issue
POST/PATCH calls whose --body/--body-file/heredoc content contains
hard-wrapped prose paragraphs (mid-paragraph manual newlines).

GitHub renders a hard-wrapped paragraph as choppy, broken text. Each prose
paragraph should be one long line so GitHub can soft-wrap it. This has been
violated even with the rule saved in memory, because it depends on
remembering to self-check before running the command -- so the check is
mechanical here instead.

Expects Claude Code PreToolUse JSON on stdin: {"tool_input": {"command": "..."}}.
Exits 0 always; prints {} (allow) or a deny decision as JSON on stdout.
"""
import json
import re
import sys
import os

ALLOW = "{}"

GH_SUBCOMMAND_RE = re.compile(
    r"\bgh\s+(pr\s+(create|edit|comment|review)|issue\s+(create|edit|comment))",
    re.IGNORECASE,
)
GH_API_RE = re.compile(r"\bgh\s+api\b", re.IGNORECASE)
API_ENDPOINT_RE = re.compile(r"/(comments|issues|pulls)(?:/|\s|$|\"|')", re.IGNORECASE)
API_METHOD_RE = re.compile(r"(-X|--method)\s*[= ]?\s*(POST|PATCH)", re.IGNORECASE)
API_GET_RE = re.compile(r"(-X|--method)\s*[= ]?\s*GET\b", re.IGNORECASE)
# gh api sends a POST when it has fields or --input, even without -X.
API_BODY_RE = re.compile(r"(?:(?:-f|-F|--field|--raw-field)[= ]body=|--input[= ])")


def is_relevant(cmd):
    if GH_SUBCOMMAND_RE.search(cmd):
        return True
    if GH_API_RE.search(cmd) and API_ENDPOINT_RE.search(cmd):
        if API_METHOD_RE.search(cmd):
            return True
        if API_BODY_RE.search(cmd) and not API_GET_RE.search(cmd):
            return True
    return False

# Lines that start a non-prose block: lists, headings, quotes, tables, code fences.
NON_PROSE_START_RE = re.compile(r"^\s{0,3}(?:[-*+>|`#]|\d+[.)]\s)")
HR_RE = re.compile(r"^\s{0,3}(?:-{3,}|={3,})\s*$")


def extract_body_texts(cmd):
    texts = []

    # Heredocs: <<EOF ... EOF / <<'EOF' ... EOF / <<-EOF ... EOF
    for m in re.finditer(r"<<-?\s*(['\"]?)(\w+)\1\r?\n(.*?)\r?\n\2\b", cmd, re.S):
        texts.append(m.group(3))

    # --body-file <path> / --body-file=<path>
    for m in re.finditer(r"--body-file[= ]+\"?([^\"\s]+)\"?", cmd):
        path = os.path.expanduser(m.group(1))
        if os.path.isfile(path):
            try:
                with open(path, encoding="utf-8") as f:
                    texts.append(f.read())
            except OSError:
                pass

    # --body '...'  or  --body "..."
    for m in re.finditer(
        r"--body[= ](?:'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\")", cmd, re.S
    ):
        texts.append(m.group(1) if m.group(1) is not None else m.group(2))

    # gh api field syntax: -f body=... / --field body=... / --raw-field body=...
    for m in re.finditer(
        r"(?:-f|--field|--raw-field)[= ]body=(?:'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\")",
        cmd,
        re.S,
    ):
        texts.append(m.group(1) if m.group(1) is not None else m.group(2))

    # gh api -F body=@<path>: the body is read from a file
    for m in re.finditer(r"(?:-F|--field)[= ]body=@\"?([^\"\s]+)\"?", cmd):
        text = read_file(m.group(1))
        if text is not None:
            texts.append(text)

    # gh api --input <path>: a JSON payload whose "body" is the text
    for m in re.finditer(r"--input[= ]+\"?([^\"\s]+)\"?", cmd):
        text = read_file(m.group(1))
        if text is None:
            continue
        try:
            payload = json.loads(text)
        except ValueError:
            continue
        if isinstance(payload, dict) and isinstance(payload.get("body"), str):
            texts.append(payload["body"])

    return texts


def read_file(path):
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        return None
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError:
        return None


def flagged_blocks(text):
    """Return prose paragraph blocks (as line lists) that look hand-wrapped."""
    flagged = []
    in_fence = False
    for block in re.split(r"\n[ \t]*\n", text):
        lines = [l for l in block.split("\n") if l.strip() != ""]
        if len(lines) <= 1:
            continue
        # Skip if the block contains (or is entirely inside) a code fence.
        if any(l.strip().startswith("```") for l in lines):
            continue
        first = lines[0]
        if NON_PROSE_START_RE.match(first) or HR_RE.match(first):
            continue
        lens = [len(l) for l in lines]
        # Signature of manual ~72-80 char wrapping: every line short, more than one line.
        if all(l <= 100 for l in lens):
            flagged.append(lines)
    return flagged


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        print(ALLOW)
        return

    cmd = (data.get("tool_input") or {}).get("command") or ""
    if not is_relevant(cmd):
        print(ALLOW)
        return

    bodies = extract_body_texts(cmd)
    if not bodies:
        print(ALLOW)
        return

    for text in bodies:
        blocks = flagged_blocks(text)
        if blocks:
            example = " / ".join(blocks[0][:2])
            reason = (
                "Blocked: this GitHub body looks hard-wrapped mid-paragraph "
                "(a prose block has multiple lines all under ~100 chars -- the "
                "signature of manual ~72-80 char wrapping). GitHub renders that as "
                "choppy, broken text. Collapse each prose paragraph to ONE long "
                "line and let GitHub soft-wrap it; blank lines still separate "
                "paragraphs, and lists/headings/quotes/tables/code fences are "
                "unaffected. Flagged block starts: " + example
            )
            print(
                json.dumps(
                    {
                        "hookSpecificOutput": {
                            "hookEventName": "PreToolUse",
                            "permissionDecision": "deny",
                            "permissionDecisionReason": reason,
                        }
                    }
                )
            )
            return

    print(ALLOW)


if __name__ == "__main__":
    main()
