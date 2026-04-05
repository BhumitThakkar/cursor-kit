---
name: devops
description: Blue-green deploy, Docker, auto-scaling, IaC, health checks, SSL, logs, DR, backup verification. Use for deployment and infra.
---

# DevOps Skill

## When to Use

- User asks for "deploy", "Docker", "blue-green", "health check", or "backup".
- Setting up or changing CI/CD or infrastructure.

## Instructions

1. **Deploy**
   - Blue-green (or canary); health check every 30s post-deploy.
   - Auto-rollback if error rate >1% spike; document threshold.

2. **Containers**
   - Dockerfile multi-stage; Docker Compose for local; non-root when possible.

3. **Backup and DR**
   - Daily backup verification; monthly DR drill; RTO/RPO documented.

4. **HTTPS and logs**
   - HTTPS only; centralized logs and retention.

## Safety Checklist

- [ ] Blue-green; health check 30s; auto-rollback on error spike
- [ ] Daily backup verification; monthly DR
- [ ] HTTPS enforced
