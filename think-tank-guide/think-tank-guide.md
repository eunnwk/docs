---
title: Think Tank 가이드
status: ✅ 배포됨
url: https://think-tank-guide.netlify.app/
updated: 2026-03-24
note:
---
# 개인 Think Tank 세팅 가이드
> Claude Code + Obsidian으로 지식 필터링 시스템 만들기  
> 비개발자도 따라할 수 있는 단계별 가이드

---

## 이게 뭔가요?

**Think Tank**는 정보를 그냥 저장하는 게 아니라, **걸러서** 저장하는 시스템이에요.

```
기사/PDF/영상 → Claude Code (필터) → Obsidian (저장)
```

- **Claude Code** = 내가 던진 정보를 자동으로 검증해주는 AI 엔진
- **Obsidian** = 검증된 지식만 모아두는 노트 앱
- **둘 사이를 연결하는 건** = 나 (지금은 수동, 나중에 자동화 가능)

### 왜 필요한가요?
정보는 많은데 머릿속에 남는 게 없다면 → 필터링 없이 너무 많이 받아들이고 있는 거예요.  
이 시스템은 정보를 받을 때마다 **4가지 질문**을 자동으로 던져줘요:

1. **출처** — 1차 자료인가, 누군가의 해석인가?
2. **근거** — 데이터/사실인가, 의견/추측인가?
3. **반대 시나리오** — 이게 틀릴 수 있는 조건은?
4. **적용성** — 나한테 실제로 해당되는가?

---

## 준비물

### 1. Claude Code 설치
터미널에서 아래 명령어 실행:
```bash
npm install -g @anthropic-ai/claude-code
```

> **터미널이 뭔가요?**  
> 맥: `Command + Space` → "터미널" 검색 → 실행  
> 검은 화면에 글자 입력하는 곳이에요.

> **npm이 없다고 나오면?**  
> https://nodejs.org 에서 Node.js 설치 후 다시 시도하세요.

### 2. Obsidian 설치
https://obsidian.md 에서 무료 다운로드 후 설치  
볼트(Vault) 하나 만들어두세요. 위치는 어디든 상관없어요.

---

## Step 1. think-tank 폴더 만들기

터미널을 열고 아래 명령어를 **한 줄씩** 입력하세요:

```bash
mkdir ~/think-tank
cd ~/think-tank
claude
```

- `mkdir ~/think-tank` — 홈 폴더에 think-tank 폴더 생성
- `cd ~/think-tank` — 그 폴더로 이동
- `claude` — Claude Code 실행

> **폴더 위치가 헷갈리면?**  
> `~/think-tank`는 `/Users/내컴퓨터이름/think-tank`와 같아요.

---

## Step 2. 신뢰 설정

Claude Code가 실행되면 이런 화면이 나와요:

```
Quick safety check: Is this a project you created or one you trust?
1. Yes, I trust this folder
2. No, exit
```

**`1` 입력 후 Enter** 를 누르세요.

---

## Step 3. 핵심 파일 생성

Claude Code가 열리면 아래 내용을 **전체 복사해서 붙여넣기** 하세요.  
⚠️ **[수정 필요한 부분]** 만 본인 정보로 바꾸세요.

```
아래 구조로 파일들을 만들어줘.

1. CLAUDE.md 파일:
---
# About Me
[본인을 한 줄로 소개 — 예: 나는 UX 디자이너이며 Make.com 자동화를 공부하고 있다]
비개발자이며, 노코드 자동화(Make.com)를 중심으로 공부하고 있다.

# 지식을 쌓는 목적 (우선순위 순)
1. [목적 1 — 예: Make.com / AI 자동화 공부 → 실무에 바로 적용]
2. [목적 2 — 예: 자동화로 수익 창출 가능한 아이디어 발굴]
3. [목적 3 — 예: 팀 운영에 쓸 인사이트]
4. [목적 4 — 예: 개인 브랜드 운영]

# 행동 규칙
- 정보를 받으면 반드시 4단계 검증을 거친다
- 검증 없이 수용 금지
- 인사이트는 항상 내 목적 중 어디에 쓰이는가로 연결할 것
- 저장 경로는 Obsidian 볼트 기준으로 안내할 것

# Obsidian 볼트 경로
[본인의 Obsidian 볼트 경로 — 예: /Users/username/Documents/Obsidian Vault]
---

2. CONTEXT.md 파일:
---
# 현재 진행 중인 것들
- Think Tank 시스템 구축 중
- [현재 진행 중인 프로젝트나 공부 내용 추가]
---

3. memory/ 폴더 생성
4. inbox/ 폴더 생성
5. sessions/ 폴더 생성

6. .claude/commands/intake/index.md 파일:
---
description: "기사, 글, 텍스트를 붙여넣을 때 자동 실행"
---

# 지식 인테이크 검증 프로토콜

사용자가 기사, 글, 스레드, 텍스트를 붙여넣으면 아래 4단계를 자동 실행한다.

## 4단계 검증
① 출처 — 1차 자료인가, 누군가의 해석인가?
② 근거 — 데이터/사실인가, 의견/추측인가?
③ 반대 시나리오 — 이게 틀릴 수 있는 조건은?
④ 적용성 — 내 목적(자동화공부 / 수익 / 업무 / 브랜드) 중 어디에 쓰이는가?

## 저장 안내
검증 후 Obsidian의 어느 폴더에 저장할지 추천한다.
---
```

완료되면 이런 메시지가 나와요:
```
모두 완료했습니다. 생성된 구조:
think-tank/
├── CLAUDE.md          ✅
├── CONTEXT.md         ✅
├── memory/            ✅
├── inbox/             ✅
├── sessions/          ✅
└── .claude/
    └── commands/
        └── intake/
            └── index.md  ✅
```

---

## Step 4. Obsidian 폴더 구조 설정

Obsidian 앱을 열고, 본인 볼트에 아래 폴더 구조를 만드세요.  
**기존 폴더가 있다면 새로 만들 필요 없어요** — 기존 폴더를 활용하면 됩니다.

### 추천 폴더 구조 (없으면 만들기)
```
📥 Inbox/          ← 임시 투하 (처음엔 여기에 다 넣기)
🤖 References/
   └── AI-automation/   ← 자동화 공부 인사이트
   └── UX/              ← 업무 관련
💡 Ideas/
   └── Business/        ← 수익 아이디어
   └── Brand/           ← 개인 브랜드
```

---

## Step 5. Obsidian 경로를 CLAUDE.md에 업데이트

Claude Code에 아래를 입력하세요 (경로와 폴더명은 본인 것으로 수정):

```
CLAUDE.md의 Obsidian 저장 경로를 아래로 업데이트해줘:

- 📥 임시 투하 → Inbox/
- 🤖 자동화 공부 → References/AI-automation/
- 💼 업무/UX → References/UX/
- 💰 수익 아이디어 → Ideas/Business/
- 🎨 브랜드 → Ideas/Brand/
```

---

## Step 6. 테스트 — 기사 한 개 던져보기

이제 실제로 작동하는지 확인해볼게요.

1. 인터넷에서 관심 있는 기사를 찾아요
2. 기사 텍스트 전체를 복사해요
3. Claude Code에 그냥 붙여넣기해요
4. 자동으로 4단계 검증이 실행되는 걸 확인해요
5. "References/AI-automation/ 에 저장하세요" 같은 안내를 확인해요
6. Obsidian을 열어서 해당 폴더에 노트를 만들고 내용을 저장해요

> **자동 검증이 안 된다면?**  
> Claude Code에 `/intake` 를 먼저 입력한 뒤 기사를 붙여넣어 보세요.

---

## 매일 사용 루틴

```
[기사 발견]
  ↓
터미널 열기
  cd ~/think-tank
  claude
  ↓
기사 붙여넣기
  ↓
4단계 검증 자동 실행
  ↓
"○○ 폴더에 저장하세요" 안내 확인
  ↓
Obsidian에서 해당 폴더에 노트 생성
  ↓
저장 완료
```

---

## 5가지 입력 경로

| 정보 유형 | 방법 | 특이사항 |
|---|---|---|
| 기사 / 글 / SNS 스레드 | Claude Code에 복붙 | 자동 4단계 검증 |
| PDF 리포트 | inbox/ 폴더에 파일 넣기 → "이거 읽어줘" | 원본 직접 분석 |
| 유튜브 영상 | NotebookLM 요약 → Claude Code에 복붙 | `[2차요약]` 태그 붙이기 |
| 책 | 독후감/핵심 내용 복붙 | 프레임워크 추출 자동 |
| 웹 리서치 | "○○에 대해 검색해줘" | 저장은 내가 직접 결정 |

### 유튜브 처리 예시
```
[2차요약] 아래는 NotebookLM이 요약한 내용이야.
원본이 아닌 AI 해석본임을 감안해서 분석해줘.

(NotebookLM 결과 붙여넣기)
```

---

## 여러 기사 한 번에 처리하기

```
아래 기사들을 순서대로 각각 4단계 검증해줘.
저장 경로도 각각 추천해줘.

[기사1 전체 텍스트]
---
[기사2 전체 텍스트]
---
[기사3 전체 텍스트]
```

---

## 폴더 구조 최종 확인

```
~/think-tank/                    ← Claude Code 작업 공간
├── CLAUDE.md                    ← 나는 누구 + 행동 규칙
├── CONTEXT.md                   ← 지금 뭘 하고 있는지
├── memory/                      ← 장기 기억
├── inbox/                       ← 기사/PDF 임시 투하
├── sessions/                    ← 과거 대화 아카이브
└── .claude/
    └── commands/
        └── intake/
            └── index.md         ← 자동 4단계 검증 스킬

~/Documents/Obsidian Vault/      ← 지식 저장소
├── Inbox/
├── References/
│   ├── AI-automation/
│   └── UX/
└── Ideas/
    ├── Business/
    └── Brand/
```

---

## 자주 묻는 질문

**Q. think-tank 폴더는 Obsidian 안에 만들어야 하나요?**  
A. 아니요! 완전히 별개예요. think-tank는 필터 엔진, Obsidian은 저장소예요.

**Q. 둘이 자동으로 연결되나요?**  
A. 지금은 수동이에요. Claude Code가 "어디에 저장하세요"라고 알려주면, 내가 직접 Obsidian에 붙여넣어요. Make.com으로 자동화도 가능해요.

**Q. Claude Code를 매번 새로 실행해야 하나요?**  
A. 네. 쓸 때마다 터미널에서 `cd ~/think-tank` → `claude` 입력하면 돼요.

**Q. CLAUDE.md는 뭔가요?**  
A. Claude Code에게 "나는 이런 사람이야"를 알려주는 파일이에요. 매 대화 시작 시 자동으로 읽혀요.

---

*Think Tank Guide v1.0 · 2026.03*
