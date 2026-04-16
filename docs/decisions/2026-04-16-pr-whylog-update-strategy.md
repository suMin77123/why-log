# PR Why Log Update Strategy

**Date:** 2026-04-16
**Status:** Accepted
**Scope:** skills/why-log/SKILL.md, skills/why-pr/SKILL.md

## Context

PR 생성 시 Why Log 섹션이 정상 포함되지만, 이후 커밋 추가로 PR을 업데이트하면 Why Log이 갱신되지 않거나 사라지는 문제. PR body는 생성 시점에만 작성되고, 이후 변경을 반영하는 로직이 없었음.

## Decision

스킬 지시문에 PR 업데이트 로직을 추가하여, AI가 기존 PR에 커밋을 추가할 때 `gh pr edit --body`로 Why Log 섹션을 갱신하도록 한다.

## Alternatives Considered

### Skill instruction update (PR body edit)
- **Description:** AI가 기존 PR body를 읽고, Why Log 섹션을 최신 decision logs 기반으로 교체
- **Pros:** 추가 인프라 불필요, 기존 플러그인 구조에 자연스럽게 통합, 즉시 적용 가능
- **Cons:** AI가 PR body를 파싱하고 섹션을 교체해야 하는 복잡성

### PR comment separation
- **Description:** Why Log을 PR body가 아닌 별도 코멘트로 작성, 업데이트 시 코멘트만 교체
- **Pros:** PR body 편집과 독립적, body가 변경되어도 Why Log이 보존됨
- **Cons:** body보다 눈에 덜 띔, 리뷰어가 코멘트를 별도로 찾아야 함

### GitHub Actions automation
- **Description:** push 이벤트에 워크플로우를 트리거하여 decision 파일을 파싱하고 PR body를 자동 갱신
- **Pros:** AI 의존 없이 항상 최신 유지, 일관성 보장
- **Cons:** 레포마다 워크플로우 설정 필요, 플러그인 범위를 넘어감, 유지보수 부담

## Reasoning

스킬 지시문 업데이트가 가장 현실적. 플러그인의 핵심 가치는 제로 인프라에서 동작하는 것인데, GitHub Actions는 레포별 설정이 필요하고 플러그인 범위를 넘어감. PR comment 방식은 가시성이 떨어져 리뷰어 경험이 나빠짐. 스킬 지시문만 수정하면 기존 PR body의 Why Log 섹션을 찾아서 교체하는 패턴으로 간단하게 해결 가능.

## Trade-offs Accepted

- AI가 PR body를 파싱해야 하므로 body 구조가 예상과 다르면 실패할 수 있음 (마커 주석으로 대응)
- AI가 관여하지 않는 수동 PR 업데이트에는 적용 불가 (현재 요구사항에서 불필요)

## Related Code Paths

- `skills/why-log/SKILL.md` - Auto PR Inclusion 섹션에 업데이트 로직 추가
- `skills/why-pr/SKILL.md` - 수동 PR 생성 스킬에도 동일 로직 추가

## Consequences

- PR에 커밋이 추가되어도 Why Log이 항상 최신 상태로 유지됨
- 새로운 decision log가 생기면 PR body에 자동 반영
- 향후 PR body 포맷 변경 시 마커 기반 파싱 로직도 함께 업데이트 필요
