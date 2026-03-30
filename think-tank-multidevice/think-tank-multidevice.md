---
title: think-tank-multidevice
status: ✅ 배포됨
url: https://think-tank-multidevice.netlify.app/
updated: 2026-03-24
note:
---
```

저장 후 닫기

---

**3. Templater 템플릿 폴더 설정**

Settings → Templater → Template folder location  
→ `guides` 입력 후 저장

---

**4. 새 노트 만들 때 사용법**

새 노트 만들고 → `Command + P` → "Templater: Open Insert Template Modal" → `_template-guide` 선택

그러면 상단에 자동으로 들어가요.

---

**5. status 값은 이렇게 쓰면 돼요**
```
📝 작성중
✅ 배포됨
🔒 비공개
📦 보관# Think Tank — 멀티 컴퓨터 사용 가이드
> GitHub로 연동된 think-tank를 어느 컴퓨터에서든 이어서 사용하는 방법  
> `eunnwk/think-tank` · Private · 2026.03

---

## 구조 이해

```
맥북프로 (회사)
    ↕  git push / pull
  GitHub (eunnwk/think-tank)
    ↕  git push / pull
윈도우 데스크탑 (집)
```

> 💡 작업 시작 전 `git pull`, 끝난 후 `git push` — 이 두 가지만 기억하면 돼요.

---

## 시나리오 A — 맥북프로 (이미 세팅됨)

### 작업 시작할 때

```bash
# 1. think-tank 폴더로 이동
cd ~/think-tank

# 2. 다른 컴퓨터 내용 받기
git pull

# 3. Claude Code 실행
claude
```

### 작업 끝날 때

```bash
git add .
git commit -m "오늘 작업"
git push
```

---

## 시나리오 B — 새 컴퓨터에서 처음 세팅

집 윈도우 데스크탑처럼 **처음 쓰는 컴퓨터**라면 아래 순서대로 한 번만 하면 돼요.

### 1. Claude Code 설치

```bash
npm install -g @anthropic-ai/claude-code
```

> 💡 npm이 없다고 나오면 [nodejs.org](https://nodejs.org)에서 Node.js 먼저 설치

### 2. GitHub에서 think-tank 가져오기

```bash
git clone https://github.com/eunnwk/think-tank.git
cd think-tank
```

### 3. Claude Code 실행

```bash
claude
```

> 💡 "trust this folder?" 물으면 `1` 입력 후 Enter

---

✅ 클론 이후부터는 맥북과 똑같이 `git pull` 시작 / `git push` 마무리 루틴으로 쓰면 돼요.

### 클론 이후 매일 루틴

```bash
# 작업 시작
cd think-tank
git pull
claude

# 작업 끝
git add .
git commit -m "오늘 작업"
git push
```

---

## 자주 겪는 상황

### git push 할 때 로그인 요청이 뜨면?

GitHub Personal Access Token 발급이 필요해요.

1. github.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → `repo` 체크 → 생성
3. 비밀번호 입력 창에 토큰 붙여넣기

---

### git pull 할 때 충돌이 나면?

Claude Code에 그대로 말하면 해결해줘요.

```
git pull 하다가 충돌 났어. 해결해줘.
```

---

### think-tank 폴더 위치가 헷갈리면?

```bash
# 맥
find ~ -name "think-tank" -type d 2>/dev/null
```

```powershell
# 윈도우 PowerShell
Get-ChildItem -Path $HOME -Recurse -Directory -Filter think-tank
```

---

## 한눈에 보기

```
새 컴퓨터 (처음 한 번)
  npm install -g @anthropic-ai/claude-code
  git clone https://github.com/eunnwk/think-tank.git
  cd think-tank → claude

매일 시작
  cd ~/think-tank (또는 cd think-tank)
  git pull
  claude

매일 마무리
  git add .
  git commit -m "오늘 작업"
  git push
```

---

*Think Tank Multi Device Guide v1.0 · 2026.03*
