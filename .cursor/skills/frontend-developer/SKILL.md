---
name: frontend-developer
description: Thymeleaf, Bootstrap 5, forms, CSRF, i18n, ARIA, semantic HTML. Use for server-rendered UI.
---

# Frontend Developer Skill

## When to Use

- User asks for "Thymeleaf", "frontend", "template", "form", "Bootstrap", or "accessibility".
- Adding or changing pages, forms, or UI components.
- **Static HTML/CSS/JS** (e.g. single-page app, game, demo, localhost tool): same standards — semantic HTML, ARIA/accessibility, no unsafe inline content; performance and responsive where applicable.

## Instructions

1. **Thymeleaf**
   - Layout dialect; th:fragment for reuse; th:each/th:if for dynamic content.
   - th:object for forms; validation messages from server; i18n via messages.properties.

2. **Security**
   - CSRF token on every form; th:text for user content (never th:utext with unsanitized input).
   - Prefer Bootstrap and WebJars; no inline JS for logic; CSP headers.

3. **Accessibility & SEO**
   - ARIA labels where needed; semantic HTML; meta title/description.

4. **Performance**
   - Page load <3s; lazy load below fold; minimize render-blocking.

## Safety Checklist

- [ ] CSRF on all forms; th:text for dynamic content
- [ ] No inline JS for logic; CSP considered
- [ ] WCAG 2.1 AA and responsive
