---
name: thymeleaf-patterns
description: Thymeleaf + Spring Boot UI conventions, fragment patterns, form handling, and accessibility standards for this project.
---

# Thymeleaf Patterns

## When to Use

- Authoring or reviewing Thymeleaf templates, fragments, forms, or static asset wiring in Spring Boot.
- Hardening XSS, CSP, i18n, or accessibility before release.

## Template structure

```
src/main/resources/templates/
  ├── fragments/
  │   ├── layout.html        # Base layout — header, nav, footer
  │   ├── header.html        # Site header fragment
  │   ├── nav.html           # Navigation fragment
  │   └── alerts.html        # Success/error flash message fragment
  ├── events/
  │   ├── list.html
  │   ├── detail.html
  │   └── form.html
  └── bookings/
      ├── form.html
      └── confirmation.html
```

## Base layout fragment

```html
<!-- fragments/layout.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title th:text="${pageTitle} + ' | Temple'">Temple</title>
  <link rel="stylesheet" th:href="@{/css/main.css}">
</head>
<body>
  <header th:replace="~{fragments/header :: header}"></header>
  <nav th:replace="~{fragments/nav :: nav}"></nav>

  <main id="main-content" role="main">
    <div th:replace="~{fragments/alerts :: alerts}"></div>
    <div th:replace="${content}"></div>
  </main>

  <footer th:replace="~{fragments/footer :: footer}"></footer>
</body>
</html>
```

## Using the layout in a page

```html
<!-- events/list.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      th:replace="~{fragments/layout :: layout(content=~{::main-content})}">
<body>
  <th:block th:fragment="main-content">
    <h1>Upcoming Events</h1>
    <!-- page content here -->
  </th:block>
</body>
</html>
```

## Form pattern (correct CSRF + validation)

```html
<form th:action="@{/bookings}" th:object="${bookingRequest}" method="post">

  <!-- Name field with label and error -->
  <div class="form-group">
    <label for="name">Full Name</label>
    <input type="text"
           id="name"
           th:field="*{name}"
           class="form-control"
           th:classappend="${#fields.hasErrors('name')} ? 'is-invalid'"
           placeholder="Enter your full name"
           required>
    <span class="invalid-feedback"
          th:if="${#fields.hasErrors('name')}"
          th:errors="*{name}">Name error</span>
  </div>

  <!-- Select field -->
  <div class="form-group">
    <label for="hallType">Hall Type</label>
    <select id="hallType" th:field="*{hallType}" class="form-control">
      <option value="">-- Select --</option>
      <option th:each="type : ${hallTypes}"
              th:value="${type}"
              th:text="${type.displayName}">Hall</option>
    </select>
  </div>

  <!-- Date field -->
  <div class="form-group">
    <label for="eventDate">Event Date</label>
    <input type="date"
           id="eventDate"
           th:field="*{eventDate}"
           class="form-control"
           required>
  </div>

  <button type="submit" class="btn btn-primary">Submit Booking</button>
</form>
```

## Displaying flash messages

```html
<!-- fragments/alerts.html -->
<th:block th:fragment="alerts">
  <div class="alert alert-success"
       th:if="${successMessage}"
       role="alert"
       th:text="${successMessage}">
  </div>
  <div class="alert alert-danger"
       th:if="${errorMessage}"
       role="alert"
       th:text="${errorMessage}">
  </div>
</th:block>
```

```java
// In controller — redirect with flash message
redirectAttributes.addFlashAttribute("successMessage", "Booking confirmed!");
return "redirect:/bookings";
```

## Iteration patterns

```html
<!-- List with empty state -->
<th:block th:if="${not #lists.isEmpty(events)}">
  <ul class="event-list">
    <li th:each="event : ${events}" class="event-item">
      <a th:href="@{/events/{id}(id=${event.id})}"
         th:text="${event.title}">Event Title</a>
      <span th:text="${#temporals.format(event.date, 'dd MMM yyyy')}">Date</span>
    </li>
  </ul>
</th:block>

<div class="empty-state" th:if="${#lists.isEmpty(events)}">
  <p>No events scheduled. Check back soon.</p>
</div>
```

## Security integration

```html
<!-- Show content only to authenticated users -->
<div th:if="${#authorization.expression('isAuthenticated()')}">
  <a th:href="@{/admin}">Admin Panel</a>
</div>

<!-- Show content only to admins -->
<div th:if="${#authorization.expression('hasRole(''ADMIN'')')}">
  <a th:href="@{/admin/events/new}">Add Event</a>
</div>
```

## URL patterns

```html
<!-- Always use @{} — never hardcode paths -->
<a th:href="@{/events}">Events</a>
<a th:href="@{/events/{id}(id=${event.id})}">View Event</a>
<a th:href="@{/events/{id}/edit(id=${event.id})}">Edit</a>
<img th:src="@{/images/{name}(name=${event.imageFile})}" th:alt="${event.title}">
<link rel="stylesheet" th:href="@{/css/main.css}">
```

## Accessibility checklist

- Every `<input>` has a `<label>` with matching `for` attribute or wraps the input
- Every `<img>` has meaningful `alt` text
- Form errors are associated with their inputs via `aria-describedby` or `th:errors`
- Interactive elements are keyboard-reachable
- Page has a single `<h1>` — heading hierarchy is logical
- `<main role="main">` wraps the primary content
- Skip-to-main link at top of page for screen reader users
- Meet **WCAG 2.1 AA** for colour contrast, focus visibility, and error identification

## i18n (`messages.properties`)

- Externalise all user-visible strings: `#{msg.key}`; provide `messages_en.properties`, `messages_hi.properties`, etc. as needed.
- Never ship placeholder English in production templates without ticket tracking.

## WebJars (Bootstrap 5 / jQuery)

- Prefer WebJars + local bundling over ad-hoc CDNs unless Zeus approves an exception.
- Pin WebJar versions in `pom.xml` / Gradle.

## `th:utext` safety

- Default to `th:text`. Use `th:utext` **only** for sanitised or fully trusted HTML; pipe user content through OWASP Java HTML Sanitizer or similar.

## Content Security Policy (CSP)

- Align inline scripts/styles with nonce/hash policy; avoid broad `unsafe-inline` in production.

## Performance budget

- Critical path for primary pages: aim for usable render under **3 seconds** on target network; compress images, minimise blocking JS, leverage HTTP caching headers.

## No inline application logic

- Keep business rules out of large `onclick` attributes; prefer external JS modules.

## Safety Checklist

- [ ] CSRF via `th:action` on mutating forms
- [ ] Labels + alt text complete
- [ ] `th:utext` reviewed for trust boundary
- [ ] CSP compatible with chosen script/style strategy
