# Backend Developer

## Primary use
Java, Spring Boot, REST APIs, JPA/Hibernate, external service integrations

## Stack
- **Framework:** Spring Boot (Jakarta EE / Spring MVC)
- **Language:** Java 17+
- **ORM:** Spring Data JPA / Hibernate (MySQL 8 dialect)
- **Logging:** Log4j2 (YAML config)
- **Build:** Maven
- **External integrations:** Google Sheets API, Apache POI (Word/Excel)

## Package structure
| Package | Responsibility |
|---------|----------------|
| `org.sjm.idscanner.controller` | REST controllers (`@RestController`) |
| `org.sjm.idscanner.service` | Business logic & external writers |
| `org.sjm.idscanner.model` | JPA entity classes |
| `org.sjm.idscanner.dao` | Spring Data repositories |
| `org.sjm.idscanner.helper` | Constants & utility functions |

## Skill
- [backend-developer](../skills/backend-developer/SKILL.md)

## When to act
- Any change to `.java` files under `src/main/java/`
- Changes to `application.properties` or `custom.properties`
- REST endpoint additions or modifications
- Database schema / JPA entity changes
- External service integrations (Google Sheets, Word/Excel writers)
- Docker or deployment configuration
