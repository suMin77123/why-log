# Decision Log

AI 의사결정 과정을 코드와 함께 기록하는 Claude Code 플러그인입니다. 결정 사항, 고려한 대안, 트레이드오프를 변경 단위별 마크다운 문서로 저장합니다.

## 왜 필요한가

AI 코드 어시스턴트가 만든 코드는 "왜 이렇게 했는지"의 맥락이 사라집니다. PR 리뷰어는 **무엇이** 바뀌었는지만 보고 **왜** 바뀌었는지 알 수 없습니다. 개발자 본인도 세션이 끝나면 의사결정 근거를 잊습니다. 이 플러그인은 `docs/decisions/`에 결정 로그를 자동으로 기록하여 코드와 함께 버전 관리합니다.

## 설치

### GitHub에서 설치

```
/install github:suMin77123/decision-log
```

### Claude Code 공식 마켓플레이스

```
/plugin install decision-log@claude-plugins-official
```

## 작동 방식

### 반자동 (스킬)

대화 중 Claude가 중요한 의사결정 시점을 감지하면 **자동으로 트리거**됩니다:

- 아키텍처 선택 (JWT vs 세션)
- 라이브러리/의존성 선택 (Prisma vs TypeORM)
- 플랜 승인 또는 수정
- 버그 원인 분석
- 성능/보안 판단
- 구현 중 분기점
- 트레이드오프 해소
- 리팩토링 결정

트리거되면 Claude가 확인을 요청합니다:

```
기록할 만한 결정을 발견했습니다:
**인증 전략: 세션 기반 대신 JWT 토큰 선택**

docs/decisions/에 기록할까요? (yes/no)
```

### 수동 (`/decision-log`)

언제든 수동으로 결정 로그를 작성할 수 있습니다:

```
/decision-log 인증 전략
```

### PR 생성 (`/decision-pr`)

결정 요약이 자동으로 포함된 PR을 생성합니다:

```
/decision-pr main
```

현재 브랜치의 모든 결정 로그를 수집하여 PR 본문에 **Decision Log** 섹션을 추가합니다. 리뷰어가 변경 이유를 즉시 확인할 수 있습니다.

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

## Hook 설정 (선택사항)

### 세션 시작 리마인더

플러그인과 함께 자동 설치됩니다. 세션 시작 시 기존 결정 로그 수와 함께 리마인더를 표시합니다.

### 커밋 시 결정 로그 자동 스테이징

git pre-commit 훅을 설치하면 커밋할 때 결정 로그가 자동으로 포함됩니다:

```bash
# 방법 1: 복사
cp hooks/pre-commit-stage-decisions .git/hooks/pre-commit

# 방법 2: 심볼릭 링크
ln -s ../../hooks/pre-commit-stage-decisions .git/hooks/pre-commit

# 실행 권한 부여
chmod +x .git/hooks/pre-commit
```

`docs/decisions/*.md` 파일이 커밋 시 자동으로 스테이징되어, 결정 로그가 항상 관련 코드와 함께 배포됩니다.

## 워크플로우 예시

### 솔로 개발자

```
1. 코딩 세션 시작
   -> SessionStart 훅: "Decision logging 활성화, 프로젝트에 3개 로그 존재"

2. Claude와 인증 방식 브레인스토밍
   -> Claude가 JWT vs 세션 vs OAuth 제시

3. JWT 선택
   -> 스킬 트리거: "기록할 결정: 인증 전략 JWT. 기록할까요? (yes/no)"
   -> "yes"
   -> docs/decisions/2026-03-30-auth-strategy-jwt.md 생성

4. 구현 계속...

5. 나중에 자신의 코드를 리뷰할 때:
   -> "왜 JWT를 선택했지?" -> docs/decisions/ 확인
```

### 팀 PR 리뷰

```
1. 개발자 + Claude 세션에서 코드 + 결정 로그 2개 생성

2. PR에 포함:
   - src/auth/jwt-handler.ts (신규)
   - src/middleware/auth.ts (수정)
   - docs/decisions/2026-03-30-auth-strategy-jwt.md (신규)
   - docs/decisions/2026-03-30-token-storage-httponly-cookies.md (신규)

3. /decision-pr로 PR 생성:
   ## Decision Log
   - **인증 전략: JWT**: 무상태 서비스 간 인증을 위해 JWT 선택
   - **토큰 저장: httpOnly 쿠키**: XSS 방지를 위해 localStorage 대신 쿠키 선택

4. 리뷰어가 결정 요약을 먼저 읽음
   -> HOW를 리뷰하기 전에 WHY를 이해
   -> "왜 이렇게 했어?" 코멘트 감소
```

## 노이즈 방지

스킬은 다음 기준을 **모두** 만족하는 결정만 기록합니다:
1. **2개 이상의 실질적 대안**이 실제로 고려됨
2. **미래 독자에게 가치** — 누군가가 이유를 이해하는 것이 유익함
3. **비자명** — 코드만 봐서는 이유를 추론할 수 없음

그리고 항상 쓰기 전에 사용자 확인을 요청합니다.

## 호환성

- [superpowers](https://github.com/obra/superpowers) 플러그인과 함께 사용 가능
- 브레인스토밍, 플랜 모드, TDD 워크플로우와 통합
- 다른 문서화 플러그인과 충돌 없음

## 라이선스

MIT
