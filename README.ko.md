# Why Log

AI 의사결정 과정을 코드와 함께 자동으로 기록하는 플러그인입니다. 결정 사항, 고려한 대안, 트레이드오프를 변경 단위별 마크다운 문서로 저장합니다. 수동 조작 없이 완전 자동으로 동작합니다.

## 왜 필요한가

AI 코드 어시스턴트가 만든 코드는 "왜 이렇게 했는지"의 맥락이 사라집니다. PR 리뷰어는 **무엇이** 바뀌었는지만 보고 **왜** 바뀌었는지 알 수 없습니다. 개발자 본인도 세션이 끝나면 의사결정 근거를 잊습니다. 이 플러그인은 `docs/decisions/`에 결정 로그를 자동으로 기록하여 코드와 함께 버전 관리합니다.

## 지원 플랫폼

| 플랫폼 | 설치 방법 |
|--------|-----------|
| **Claude Code** | `claude plugin add github:suMin77123/why-log` |
| **Cursor** | Cursor Marketplace에서 설치 또는 `.cursor-plugin/`에 클론 |
| **Codex** | [Codex 설치 가이드](.codex/INSTALL.md) 참조 |
| **Gemini CLI** | `gemini extensions install github:suMin77123/why-log` |

## 작동 방식

### 자동 (사용자 개입 0)

플러그인은 4단계로 완전 자동 동작합니다:

**1. 세션 시작** — Hook이 기존 결정 로그 수와 함께 리마인더를 주입합니다.

**2. 결정 감지** — AI가 중요한 의사결정 시점을 감지하면, 묻지 않고 즉시 기록합니다:

```
Decision logged: docs/decisions/2026-03-30-auth-strategy-jwt.md
```

트리거 시그널:
- 아키텍처 선택 (JWT vs 세션)
- 라이브러리/의존성 선택 (Prisma vs TypeORM)
- 버그 원인 분석
- 성능/보안 판단
- 플랜 승인 또는 수정
- 구현 중 분기점
- 트레이드오프 해소
- 리팩토링 결정

**3. 커밋** — AI가 코드와 함께 `docs/decisions/*.md`를 자동으로 스테이징합니다. 결정 로그와 코드가 같은 커밋에 포함됩니다.

**4. PR 생성** — AI가 PR을 만들 때 브랜치의 결정 로그를 자동 수집하여 PR 본문에 **Why Log** 섹션을 포함합니다:

```markdown
## Why Log

- **인증 전략: JWT**: JWT 토큰 사용 — 무상태 서비스 간 인증, 공유 세션 저장소 불필요
  → [`docs/decisions/2026-03-30-auth-strategy-jwt.md`](docs/decisions/2026-03-30-auth-strategy-jwt.md)

> Full reasoning and alternatives in each linked decision log.
```

### 수동 (백업용)

| 커맨드 | 용도 |
|--------|------|
| `/why-log [주제]` | AI가 놓친 결정을 직접 기록 |
| `/why-pr [베이스 브랜치]` | AI 플로우 없이 직접 PR 생성 시 |

## 결정 로그 형식

각 결정은 `docs/decisions/YYYY-MM-DD-<주제>.md`로 저장됩니다:

```markdown
# 인증 전략: JWT vs 세션

**Date:** 2026-03-30
**Status:** Accepted
**Scope:** src/auth/, src/middleware/

## Context
API 엔드포인트에 사용자 인증이 필요합니다.
여러 서비스가 독립적으로 사용자 신원을 확인해야 하는
마이크로서비스 아키텍처를 구축 중입니다.

## Decision
httpOnly 쿠키에 저장하는 JWT 토큰 방식을 사용합니다.

## Alternatives Considered

### 세션 기반 인증
- **Pros:** 단순함, 내장된 세션 무효화
- **Cons:** 서비스 간 공유 세션 저장소 필요

### OAuth2 전용
- **Pros:** 위임 인증, 업계 표준
- **Cons:** 내부 서비스 간 인증에는 과도함

## Reasoning
JWT는 공유 세션 저장소 없이 마이크로서비스 간 무상태 검증을 가능하게 합니다.
토큰 무효화의 복잡성은 현재 낮은 위험 프로필을 고려하면 수용 가능합니다.

## Trade-offs Accepted
- 토큰 무효화에 추가 인프라 필요 (MVP에는 수용 가능)
- 세션 쿠키보다 큰 요청 페이로드 (무시할 만한 영향)

## Related Code Paths
- `src/auth/jwt-handler.ts` - 토큰 생성 및 검증
- `src/middleware/auth.ts` - 요청 인증 미들웨어

## Consequences
- v2 전에 토큰 갱신 메커니즘 구현 필요
- 모든 새 서비스가 독립적으로 인증 검증 가능
```

## 노이즈 방지

스킬은 다음 기준을 **모두** 만족하는 결정만 기록합니다:
1. **2개 이상의 실질적 대안**이 실제로 고려됨
2. **미래 독자에게 가치** — 누군가가 이유를 이해하는 것이 유익함
3. **비자명** — 코드만 봐서는 이유를 추론할 수 없음

## 워크플로우 예시

```
1. 코딩 세션 시작
   -> Hook: "Decision logging 활성화, 기존 로그 3개"

2. AI와 인증 방식 브레인스토밍
   -> AI가 JWT vs 세션 vs OAuth 제시

3. JWT 선택
   -> AI가 자동으로 결정 기록
   -> "Decision logged: docs/decisions/2026-03-30-auth-strategy-jwt.md"

4. 구현 계속...

5. 코드 커밋
   -> AI가 실행: git add docs/decisions/*.md + 코드 파일
   -> 결정 로그가 같은 커밋에 포함

6. PR 생성
   -> AI가 PR 본문에 Why Log 섹션 자동 포함
   -> 리뷰어가 HOW를 보기 전에 WHY를 이해
```

## Hook 설정

### 세션 시작 리마인더
플러그인과 함께 자동 설치됩니다. 세션 시작 시 기존 결정 로그 수와 함께 리마인더를 표시합니다.

### Git Pre-commit Hook (선택사항)
AI 없이 커밋할 때를 위한 선택적 백업:

```bash
cp hooks/pre-commit-stage-decisions .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 호환성

- [superpowers](https://github.com/obra/superpowers) 플러그인과 함께 사용 가능
- 브레인스토밍, 플랜 모드, TDD 워크플로우와 통합
- 크로스 플랫폼: Claude Code, Cursor, Codex, Gemini CLI

## 라이선스

MIT
