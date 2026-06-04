# 블로그 자동화 시스템 세팅 가이드
## Blogger + Slack 버전 | 윈도우 개인 PC 기준

> 이 가이드 하나만 따라하면 처음부터 끝까지 혼자 세팅할 수 있어요.
> 각 단계마다 "이게 뭔가요?" 설명이 함께 있어요.

---

## 📋 준비물 체크리스트

시작 전에 아래 항목들이 준비되어 있는지 확인하세요.

| 항목 | 용도 | 비용 |
|------|------|------|
| Google 계정 | Blogger 블로그 + Google Cloud | 무료 |
| Slack 워크스페이스 | 알림 수신 | 무료 |
| Anthropic API 키 | AI 글쓰기 엔진 | 유료 (종량제) |
| 개인 윈도우 PC | 봇 실행 환경 | - |

> ⚠️ **중요:** 회사 네트워크에서는 일부 API 연결이 막힐 수 있어요.
> 반드시 **개인 WiFi** 환경에서 세팅하세요.

---

## 전체 흐름 한눈에 보기

```
STEP 1  Python & Git 설치          ← 엔진 설치
STEP 2  코드 다운로드               ← 설계도 가져오기
STEP 3  Blogger 블로그 개설         ← 글 올라갈 집 만들기
STEP 4  Slack 알림 설정             ← 알림 채널 연결
STEP 5  Google Cloud 설정           ← 블로그 출입증 발급
STEP 6  .env 파일 작성              ← 비밀 수첩 채우기
STEP 7  Slack 연동 코드 수정        ← Telegram → Slack 교체
STEP 8  봇 실행 테스트              ← 실제로 돌려보기
```

---

## STEP 1 | Python & Git 설치

### 이게 뭔가요?
자동화 시스템을 돌리는 "엔진"이에요.

Python은 이 프로그램이 작동하는 언어예요. 마치 유튜브를 보려면 브라우저가 필요하듯, 이 프로그램을 실행하려면 Python이 필요해요.

Git은 인터넷에 공개된 코드를 내 컴퓨터로 가져오는 도구예요.

### 📋 따라하기

**① Python 설치**

1. **python.org/downloads** 접속
2. 노란색 **"Download Python 3.x.x"** 버튼 클릭
3. 다운로드된 설치파일 실행
4. ⚠️ **설치 화면 하단 "Add Python to PATH" 반드시 체크!**
5. "Install Now" 클릭 → 완료

**② Git 설치**

1. **git-scm.com** 접속 → Download 클릭
2. 다운로드된 설치파일 실행
3. 모든 옵션 **기본값 그대로** Next 클릭 → 완료

**③ 설치 확인**

`Windows키 + R` → `cmd` 입력 → 엔터

```
python --version
git --version
```

| 결과 | 상태 |
|------|------|
| `Python 3.11.x` 이상 | ✅ 정상 |
| `git version 2.x.x` | ✅ 정상 |
| `'python'은(는) 인식할 수 없는 명령어` | Python 재설치 (PATH 체크 확인) |

---

## STEP 2 | 코드 다운로드

### 이게 뭔가요?
블로그 자동화 프로그램의 설계도(코드)를 인터넷에서 내 컴퓨터로 복사해요. 이 안에 트렌드 수집봇, 글쓰기봇, 발행봇이 모두 들어있어요.

### 📋 따라하기

cmd 창에서 순서대로 입력:

```
cd %USERPROFILE%\Desktop
git clone https://github.com/sinmb79/blog-writer.git
cd blog-writer
dir
```

**성공 시 보여야 할 항목:**
```
bots    config    scripts    docs
README.md    requirements.txt    .env.example
```

---

## STEP 3 | Blogger 블로그 개설

### 이게 뭔가요?
자동으로 쓴 글이 실제로 올라갈 "집"을 만들어요. Google이 운영하는 무료 블로그 서비스예요. 나중에 Google AdSense 광고를 달아 수익을 낼 수 있어요.

### 📋 따라하기

1. **blogger.com** 접속 → Google 계정으로 로그인
2. **"새 블로그 만들기"** 클릭
3. 블로그 정보 입력:

| 항목 | 내용 |
|------|------|
| 제목 | 블로그 이름 (나중에 변경 가능) |
| 주소 | 영문 주소 입력 (예: myautoblog2024) |
| 테마 | 아무거나 선택 |

4. **Blog ID 메모하기** ← 나중에 .env 파일에 입력해야 해요

블로그 생성 후 브라우저 주소창 확인:
```
https://www.blogger.com/blog/posts/[숫자 18자리]
                                     ↑ 이게 Blog ID
```

5. **블로그 주소도 메모:**
```
https://내블로그주소.blogspot.com/
```

---

## STEP 4 | Slack 알림 설정

### 이게 뭔가요?
자동화 시스템이 보내는 알림을 Slack으로 받아요. 수집된 글감 리포트, 발행 완료 알림, 오류 알림 등이 Slack 채널로 전송돼요.

**Incoming Webhook** 방식을 사용해요. 쉽게 말해 "이 특별한 주소로 메시지를 보내면 내 Slack 채널에 올라간다"는 전용 URL을 발급받는 거예요.

### 📋 따라하기

**① Slack 워크스페이스 준비**

- 기존 워크스페이스가 있으면 그대로 사용
- 없으면 slack.com에서 무료로 새로 만들기

**② 알림받을 채널 만들기**

Slack 좌측 채널 목록 하단 **"+ 채널 추가"** 클릭
채널 이름 입력: `blog-bot` → 만들기

**③ Slack App 만들기**

1. 브라우저에서 **api.slack.com/apps** 접속
2. **"Create New App"** 클릭
3. **"From scratch"** 선택
4. App Name 입력: `BlogBot`
5. 사용할 워크스페이스 선택 → **"Create App"**

**④ Incoming Webhook 활성화 & URL 발급**

1. 왼쪽 메뉴에서 **"Incoming Webhooks"** 클릭
2. 오른쪽 스위치 **"Activate Incoming Webhooks"** → ON으로 변경
3. 하단 **"Add New Webhook to Workspace"** 클릭
4. 채널 선택: `#blog-bot` → **"Allow"**
5. 생성된 **Webhook URL 복사 후 메모** ← 중요!

```
형태: https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXX
```

---

## STEP 5 | Google Cloud 설정

### 이게 뭔가요?
자동화 프로그램이 내 Blogger에 글을 올리려면 Google의 공식 허가가 필요해요. 마치 아파트 출입증처럼, 프로그램 전용 "출입증"을 발급받는 과정이에요.

### 📋 따라하기

**① Google Cloud Console 접속**

1. **console.cloud.google.com** 접속 (Blogger와 같은 Google 계정)
2. 2단계 인증 요구 시 → "설정으로 이동" → 2단계 인증 켜기 → 완료 후 재접속

**② Blogger API 활성화**

1. 상단 검색창에 `Blogger API` 입력
2. 상위 결과 첫 번째 **"Blogger API"** 클릭
3. **"사용"** 파란 버튼 클릭

**③ OAuth 클라이언트 ID 만들기**

1. 화면 오른쪽 **"사용자 인증 정보 만들기"** 클릭
2. **"사용자 데이터"** 선택 → **"다음"**
3. 앱 이름 입력 (예: `자동화블로그`)
4. 사용자 지원 이메일 → 드롭다운에서 본인 Gmail 선택 → **"다음"**
5. 범위 단계 → **"저장 후 계속"**
6. 애플리케이션 유형: **"데스크톱 앱"** 선택 → **"만들기"**
7. **"⬇ 다운로드"** 클릭 → credentials.json 파일 저장

**④ credentials.json 파일 이동**

파일 탐색기에서:
- 다운로드 폴더의 `client_secret_....json` 파일을
- `바탕화면\blog-writer\` 폴더로 이동
- 파일 이름을 `credentials.json` 으로 변경

**⑤ 테스트 사용자 추가 (필수!)**

1. Google Cloud 왼쪽 메뉴 **"OAuth 동의 화면"** 클릭
2. **"대상"** 탭 클릭
3. **"+ Add users"** 클릭
4. 본인 Gmail 주소 입력 → **"저장"**

> ⚠️ 이 단계를 빠뜨리면 나중에 `access_denied` 오류가 나요!

**⑥ 가상환경 만들기 & 패키지 설치**

cmd에서:
```
cd %USERPROFILE%\Desktop\blog-writer
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

`(venv)` 가 프롬프트 앞에 붙어있으면 가상환경 활성화 성공

**⑦ Google Refresh Token 발급**

```
python scripts\get_token.py
```

브라우저가 열리면:
1. Google 계정 로그인
2. "Google에서 확인하지 않은 앱" → **"계속"** 클릭
3. **"모두 선택"** 체크 → **"계속"**

브라우저가 자동으로 안 열리면:
- cmd에 출력된 긴 URL(`https://accounts.google.com/...`)을 복사해서 브라우저에 직접 붙여넣기

cmd에 출력된 `REFRESH_TOKEN:` 뒤의 값을 메모!

---

## STEP 6 | .env 파일 작성

### 이게 뭔가요?
프로그램이 작동하는 데 필요한 모든 키와 설정을 담는 "비밀 수첩"이에요. API 키, 블로그 ID, Slack 주소 등이 모두 여기 들어가요. 이 파일이 없으면 프로그램이 아무것도 할 수 없어요.

### 📋 따라하기

**① .env 파일 생성**

```
cd %USERPROFILE%\Desktop\blog-writer
copy .env.example .env
```

**② .env 파일 열기**

```
notepad .env
```

**③ credentials.json 값 확인**

새 cmd 창에서:
```
type %USERPROFILE%\Desktop\blog-writer\credentials.json
```

출력에서 `"client_id"` 와 `"client_secret"` 값 복사

**④ 필수 항목 채우기**

메모장에서 아래 항목들을 찾아 값 입력 후 저장(`Ctrl+S`):

```
GOOGLE_CLIENT_ID=credentials.json의 client_id 값
GOOGLE_CLIENT_SECRET=credentials.json의 client_secret 값
GOOGLE_REFRESH_TOKEN=STEP 5에서 메모한 Refresh Token
BLOG_MAIN_ID=STEP 3에서 메모한 Blog ID 18자리 숫자
BLOG_SITE_URL=https://내블로그주소.blogspot.com/
GOOGLE_SEARCH_CONSOLE_SITE=https://내블로그주소.blogspot.com/
ANTHROPIC_API_KEY=Anthropic API 키

# Slack (아래 줄을 파일 맨 아래에 추가)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/STEP4에서_복사한_URL
```

---

## STEP 7 | Slack 연동 코드 수정

### 이게 뭔가요?
원래 코드는 Telegram으로 알림을 보내도록 만들어져 있어요. 이 부분을 Slack으로 교체하는 작업이에요. 공통 전송 함수를 하나 만들어두고 봇 파일에서 불러쓰는 방식이에요.

### 📋 따라하기

**① slack_notify.py 파일 만들기**

메모장을 새로 열고 아래 내용 전체를 복사해서 붙여넣기:

```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()

SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL", "")

def send_slack_message(text: str) -> bool:
    if not SLACK_WEBHOOK_URL:
        print("[WARNING] SLACK_WEBHOOK_URL이 설정되지 않았습니다.")
        return False
    try:
        response = requests.post(
            SLACK_WEBHOOK_URL,
            json={"text": text},
            timeout=10
        )
        return response.status_code == 200
    except Exception as e:
        print(f"[ERROR] Slack 전송 실패: {e}")
        return False
```

저장 위치: `바탕화면\blog-writer\`
파일 이름: `slack_notify.py`
파일 형식: **모든 파일** 선택 후 저장 (`.txt`가 붙지 않도록!)

**② analytics_bot.py 수정**

```
notepad %USERPROFILE%\Desktop\blog-writer\bots\analytics_bot.py
```

파일 상단 import 구문 아래에 추가:
```python
from slack_notify import send_slack_message
```

파일 안에서 `Ctrl+F`로 `send_message` 검색 →
Telegram 전송 코드를 아래처럼 교체:

```python
# 기존 코드 (주석 처리 또는 삭제)
# await bot.send_message(chat_id=CHAT_ID, text=message)

# 교체 코드
send_slack_message(message)
```

저장: `Ctrl+S`

---

## STEP 8 | 봇 실행 테스트

### 이게 뭔가요?
지금까지 설정한 것들이 제대로 연결됐는지 확인해요. 수집봇 → 분석봇 순서로 테스트해요.

### 📋 따라하기

**① 필요한 폴더 생성**

```
cd %USERPROFILE%\Desktop\blog-writer
mkdir data\discarded
mkdir data\queue
mkdir data\published
mkdir data\images
mkdir logs
```

**② 가상환경 활성화**

```
venv\Scripts\activate
```

프롬프트 앞에 `(venv)` 표시되면 정상

**③ 수집봇 실행**

```
python bots\collector_bot.py
```

성공 시:
```
[INFO] === 수집봇 시작 ===
[INFO] 수집 완료 : 85개
[INFO] 합격 : 6개 / 폐기 : 79개
[INFO] === 수집봇 완료 ===
```

**④ 분석봇 실행 & Slack 알림 확인**

```
python bots\analytics_bot.py
```

Slack `#blog-bot` 채널에 리포트 메시지가 오면 성공! 🎉

---

## 🔧 자주 만나는 오류 해결법

| 오류 메시지 | 원인 | 해결법 |
|------------|------|--------|
| `'python'은(는) 인식할 수 없는 명령어` | Python PATH 설정 안됨 | Python 재설치 시 "Add to PATH" 체크 |
| `FileNotFoundError: data/discarded` | data 폴더 없음 | STEP 8의 mkdir 명령어 실행 |
| `access_denied` | 테스트 사용자 미등록 | Google Cloud → 대상 → Add users에 이메일 추가 |
| `403 Forbidden: accessNotConfigured` | Search Console API 미활성화 | 당장은 무시해도 됨 |
| `Google Trends 수집 실패: 404` | Google 일시 제한 | 무시해도 됨 (다른 소스에서 수집) |
| Slack 메시지 안 옴 | Webhook URL 오류 | .env의 SLACK_WEBHOOK_URL 다시 확인 |
| `ModuleNotFoundError` | 패키지 미설치 | `pip install -r requirements.txt` 재실행 |

---

## 📝 세팅 중 메모해야 할 정보

아래 표를 직접 채우면서 진행하세요.

| 항목 | 내 값 |
|------|------|
| Blogger Blog ID (18자리) | |
| Blogger 블로그 주소 | |
| Google Client ID | |
| Google Client Secret | |
| Google Refresh Token | |
| Slack Webhook URL | |
| Anthropic API Key | |

> ⚠️ 이 정보들은 절대 외부에 공개하지 마세요.

---

## 🗺️ 세팅 완료 후 다음 단계

```
다음에 할 것
┌──────────────────────────────────────────────┐
│  Claude API 연결 → 글 자동 생성 테스트         │
│  Blogger에 실제로 글 발행되는지 확인            │
│  Google AdSense 신청                          │
│  쿠팡 파트너스 API 연결                        │
│  스케줄러 가동 → 24시간 자동 운영 시작          │
└──────────────────────────────────────────────┘
```

---

## 💡 핵심 한 줄 요약

> 이 시스템은 여러 서비스가 파이프라인처럼 연결된 구조예요.
> 트렌드 수집 → AI 글쓰기 → Blogger 발행 → Slack 알림
> 한 번 세팅하면 이 과정이 매일 자동으로 돌아가요.

---

**참고 프로젝트:** [sinmb79/blog-writer](https://github.com/sinmb79/blog-writer) | MIT License
**작성일:** 2026년 4월 14일
