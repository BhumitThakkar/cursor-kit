---
name: frontend-developer
description: >-
  Handles HTML, CSS, and JavaScript tasks for the IDScanner Spring Boot app.
  Use when editing Thymeleaf templates, vanilla JS logic, Bootstrap UI,
  or browser APIs (camera, canvas, fetch).
---

# Frontend Developer Skill

## Project layout

| Concern | Path |
|---------|------|
| Templates | `src/main/resources/templates/*.html` |
| JavaScript | `src/main/resources/static/js/*.js` |
| CSS | `src/main/resources/static/css/*.css` |
| Images | `src/main/resources/static/img/` |

## When to use

- Editing or creating `.html`, `.js`, or `.css` files under `src/main/resources/`
- UI layout, styling, or responsive design changes
- Client-side logic: DOM manipulation, event handling, form validation
- Browser API work: `navigator.mediaDevices`, Canvas, Fetch API
- Bootstrap component usage or customisation

## Conventions

### HTML / Thymeleaf
- Use Thymeleaf `th:` attributes for server-driven content; keep client logic in external `.js` files.
- Reference JS/CSS via absolute paths from static root (`/js/home.js`, `/css/home.css`).
- Bootstrap 5.3 is loaded from CDN — prefer Bootstrap utility classes over custom CSS when possible.

### JavaScript
- Vanilla ES6+ only (no frameworks, no bundler).
- Keep all JS in `src/main/resources/static/js/` — never inline `<script>` blocks in templates.
- Use `async/await` for asynchronous code; avoid raw `.then()` chains in new code.
- Prefer `const`; use `let` only when reassignment is necessary; never use `var`.
- Communicate with the backend via `fetch('/api/…')` with JSON payloads.

### CSS
- Custom styles go in `src/main/resources/static/css/`.
- Never inline `style` attributes in HTML unless dynamically set by JS.
- Use Bootstrap grid (`row`/`col-*`) for layout.

## Checklist (run mentally before finishing)

1. No inline `<script>` or `<style>` blocks added to templates.
2. New browser APIs are wrapped in `try/catch` with a user-visible error message.
3. DOM queries use `getElementById` / `querySelector` — no jQuery.
4. `fetch` calls include error handling (`.catch` or `try/catch`).
5. UI changes are responsive (test at mobile and desktop widths conceptually).
6. Existing variable/function naming style is followed (camelCase, descriptive).
