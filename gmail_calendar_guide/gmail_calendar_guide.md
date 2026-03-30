---
title: Gmail × Google Calendar 가이드
status: ✅ 배포됨
url: https://zippy-douhua-88087b.netlify.app/
updated: 2026-03-23
note:
---
# 📧 Gmail 회의 메일 → Google Calendar 자동 등록

**Google Apps Script 설치 가이드**  
`v3` · `2026.03.23` · 버그 수정 + 회의 취소 자동 삭제 기능 추가

| 소요 시간 | 필요 조건 | 비용 |
|-----------|-----------|------|
| 약 10분 | 회사 Google 계정 | 무료 |

---

## 동작 방식

이 스크립트는 Google Apps Script를 이용해 Gmail을 자동으로 감시하고, 회의 메일이 도착하면 내용을 파싱하여 Google Calendar에 일정을 등록합니다. 회의 취소 메일이 오면 등록된 일정을 자동으로 삭제합니다.

> **ℹ️** 스크립트는 본인의 Google 계정에서만 동작합니다. 팀원 각자 설치가 필요합니다.

---

## 설치 방법

### Step 1 — Apps Script 열기

**script.google.com** 접속 → 왼쪽 상단 **[+ 새 프로젝트]** 클릭 → 프로젝트 이름을 `Gmail 회의 자동 등록`으로 변경

---

### Step 2 — Code.gs 파일에 코드 붙여넣기

① 에디터에서 `Ctrl+A` → `Delete` 로 기존 내용 삭제  
② 아래 코드 전체 복사 후 `Ctrl+V`

```javascript
// ================================================
// v3 - 2026.03.23
// 버그 수정: 시간 범위 파싱 오류 (15:00~16:00)
// 신규: 회의 취소 메일 감지 시 캘린더 일정 자동 삭제
// ================================================

const CONFIG = {
  SEARCH_QUERY: 'subject:(회의 OR 회의소집 OR 회의취소 OR 미팅 OR meeting OR Meeting) is:unread',
  PROCESSED_LABEL: '캘린더등록완료',
  LOOK_BACK_HOURS: 24,
  CALENDAR_ID: 'primary',
  GEMINI_API_KEY: '',
  DEFAULT_DURATION_MIN: 60,
};

function processMeetingEmails() {
  var label = getOrCreateLabel(CONFIG.PROCESSED_LABEL);
  var cutoff = new Date(Date.now() - CONFIG.LOOK_BACK_HOURS * 60 * 60 * 1000);
  var threads = GmailApp.search(CONFIG.SEARCH_QUERY);
  var created = 0, skipped = 0;

  for (var i = 0; i < threads.length; i++) {
    var thread = threads[i];
    var msg = thread.getMessages()[0];
    if (msg.getDate() < cutoff) continue;

    var labels = thread.getLabels();
    var alreadyDone = false;
    for (var j = 0; j < labels.length; j++) {
      if (labels[j].getName() === CONFIG.PROCESSED_LABEL) { alreadyDone = true; break; }
    }
    if (alreadyDone) { skipped++; continue; }

    var emailData = {
      subject: msg.getSubject(),
      body: msg.getPlainBody().substring(0, 2000),
      from: msg.getFrom(),
    };

    // 취소 메일 처리
    if (/취소|canceled|cancelled|cancel/i.test(emailData.subject)) {
      var cancelInfo = parseWithRegex(emailData);
      if (cancelInfo) { deleteCalendarEvent(cancelInfo); }
      thread.addLabel(label);
      skipped++;
      continue;
    }

    console.log('처리 중: ' + emailData.subject);
    var info = parseWithRegex(emailData);
    if (info) {
      createCalendarEvent(info);
      thread.addLabel(label);
      created++;
      console.log('등록완료: ' + info.title);
    } else { skipped++; }
  }
  console.log('완료 - 등록:' + created + ' 건너뜀:' + skipped);
}

function deleteCalendarEvent(info) {
  var cal = CalendarApp.getCalendarById(CONFIG.CALENDAR_ID)
    || CalendarApp.getDefaultCalendar();
  var searchStart = new Date(info.startDateTime.getTime() - 60*60*1000);
  var searchEnd   = new Date(info.startDateTime.getTime() + 60*60*1000);
  var events = cal.getEvents(searchStart, searchEnd);
  for (var i = 0; i < events.length; i++) {
    if (events[i].getTitle() === info.title) {
      events[i].deleteEvent();
      console.log('캘린더 일정 삭제: ' + info.title);
    }
  }
}

function setupTrigger() {
  var triggers = ScriptApp.getProjectTriggers();
  for (var i = 0; i < triggers.length; i++) { ScriptApp.deleteTrigger(triggers[i]); }
  ScriptApp.newTrigger('processMeetingEmails').timeBased().everyMinutes(15).create();
  console.log('트리거 설정 완료');
}

function getOrCreateLabel(name) {
  var label = GmailApp.getUserLabelByName(name);
  if (!label) label = GmailApp.createLabel(name);
  return label;
}
```

---

### Step 3 — Parser.gs 파일 추가

왼쪽 파일 목록에서 **+** 버튼 클릭 → Script → 이름: `Parser`

새로 생긴 Parser.gs 파일에 아래 코드를 붙여넣기

```javascript
// ================================================
// v2 - 2026.03.23
// 버그 수정: 15:00~16:00 형식 시간 범위 파싱 오류
// ================================================

function parseWithRegex(emailData) {
  var text = emailData.subject + '\n' + emailData.body;
  var date = null;
  var d1 = text.match(/(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})/);
  var d2 = text.match(/(\d{1,2})월\s*(\d{1,2})일/);
  if (d1) { date = d1[1]+'-'+pad(d1[2])+'-'+pad(d1[3]); }
  else if (d2) { date = new Date().getFullYear()+'-'+pad(d2[1])+'-'+pad(d2[2]); }

  // 1순위: HH:MM ~ HH:MM 범위 직접 매칭
  var hmRange = text.match(/([0-2]?\d:[0-5]\d)\s*(?:~|-)\s*([0-2]?\d:[0-5]\d)/);
  var startTime, endTime;
  var krRange = text.match(/(오전|오후)?\s*(\d{1,2})시(?:\s*(\d{1,2})분)?\s*(?:~|부터|-)\s*(오전|오후)?\s*(\d{1,2})시(?:\s*(\d{1,2})분)?/);

  if (hmRange) {
    startTime=hmRange[1]; endTime=hmRange[2];
  } else if (krRange) {
    var sAmPm=krRange[1],sH=parseInt(krRange[2]),sM=krRange[3]?parseInt(krRange[3]):0;
    var eAmPm=krRange[4]||krRange[1],eH=parseInt(krRange[5]),eM=krRange[6]?parseInt(krRange[6]):0;
    if (sAmPm==='오후'&&sH<12) sH+=12; if (sAmPm==='오전'&&sH===12) sH=0;
    if (eAmPm==='오후'&&eH<12) eH+=12; if (eAmPm==='오전'&&eH===12) eH=0;
    startTime=pad(sH)+':'+pad(sM); endTime=pad(eH)+':'+pad(eM);
  } else {
    var krTimes=[],krRe=/(오전|오후)\s*(\d{1,2})시(?:\s*(\d{1,2})분)?/g,km;
    while ((km=krRe.exec(text))!==null) {
      var h=parseInt(km[2]),m=km[3]?parseInt(km[3]):0;
      if (km[1]==='오후'&&h<12) h+=12; if (km[1]==='오전'&&h===12) h=0;
      krTimes.push(pad(h)+':'+pad(m)); }
    if (krTimes.length>=1) {
      startTime=krTimes[0]; endTime=krTimes[1]||addMinutes(krTimes[0],CONFIG.DEFAULT_DURATION_MIN);
    } else {
      var timeMatches=text.match(/([0-2]?\d):([0-5]\d)/g)||[];
      var times=timeMatches.map(function(t){var p=t.split(':');return pad(p[0])+':'+p[1];});
      times=times.filter(function(v,i,a){return a.indexOf(v)===i;}); times.sort();
      if (times.length===0) return null;
      startTime=times[0]; endTime=times[1]||addMinutes(times[0],CONFIG.DEFAULT_DURATION_MIN);
    }
  }

  var loc = '';
  var locMatch = text.match(/(?:장소|회의실|회의장소|위치|Location|Room)\s*[:：]\s*(.+)/i);
  if (locMatch) loc = locMatch[1].replace(/\*/g, '').trim();
  var titleMatch = text.match(/회의제목\s*[:：]\s*(.+)/);
  var title = titleMatch
    ? titleMatch[1].replace(/\*/g,'').trim()
    : emailData.subject.replace(/\*/g,'').trim();
  if (!date || !startTime) return null;
  var start = new Date(date+'T'+startTime+':00');
  var end   = new Date(date+'T'+endTime+':00');
  if (isNaN(start.getTime())) return null;
  return { title:title, startDateTime:start, endDateTime:end,
           location:loc, description:'자동등록\n발신: '+emailData.from, attendees:[] };
}

function createCalendarEvent(info) {
  var cal = CalendarApp.getCalendarById(CONFIG.CALENDAR_ID)
    || CalendarApp.getDefaultCalendar();
  cal.createEvent(info.title, info.startDateTime, info.endDateTime, {
    location: info.location, description: info.description,
    guests: info.attendees.join(','), sendInvites: false });
}

function pad(n) { return ('0'+n).slice(-2); }

function addMinutes(t, m) {
  var p2=t.split(':'), tot=parseInt(p2[0])*60+parseInt(p2[1])+m;
  return pad(Math.floor(tot/60))+':'+pad(tot%60); }
```

---

### Step 4 — 저장

두 파일 모두 `Ctrl+S` 로 저장

---

### Step 5 — 테스트 실행

#### ① 회의 등록 테스트

Gmail에서 본인 계정으로 아래 형식의 메일을 전송합니다.

```
제목: [회의소집] 테스트 회의 / 2026.03.25 14:00 ~ 15:00

* 회의제목 : 테스트 회의
* 회의일시 : 2026.03.25 14:00 ~ 15:00
* 회의장소 : 상암 12F 발렌시아
```

1. Apps Script에서 드롭다운 → `processMeetingEmails` 선택 → ▶ Run
2. Execution log에서 `등록완료: 테스트 회의` 확인
3. Google Calendar에서 14:00~15:00 일정 확인 ✅

#### ② 회의 취소 테스트

```
제목: [회의취소] 테스트 회의 / 2026.03.25 14:00 ~ 15:00

* 회의제목 : 테스트 회의
* 회의일시 : 2026.03.25 14:00 ~ 15:00
* 회의장소 : 상암 12F 발렌시아
```

1. Apps Script에서 `processMeetingEmails` → ▶ Run
2. Execution log에서 `캘린더 일정 삭제: 테스트 회의` 확인
3. Google Calendar에서 해당 일정이 삭제됐는지 확인 ✅

> **⚠️** 최초 실행 시 권한 허용 팝업이 뜹니다.  
> Review permissions → 본인 계정 선택 → Advanced → Go to (unsafe) → Allow 클릭

**Execution log 정상 메시지**

```
완료 - 등록:0 건너뜀:0  ← 처리할 메일 없을 때 정상
완료 - 등록:1 건너뜀:0  ← 회의 메일 1건 등록 성공
캘린더 일정 삭제: 테스트 회의  ← 취소 메일 처리 성공
```

---

### Step 6 — 자동 트리거 설정

**방법 A — 코드로 설정 (권장)**

상단 드롭다운에서 `setupTrigger` 선택 → ▶ Run

**방법 B — UI에서 직접 설정**

| 항목 | 선택값 |
|------|--------|
| Choose which function to run | `processMeetingEmails` |
| Choose which deployment | `Head` |
| Select event source | `Time-driven` |
| Select type of time | `Minutes timer` |
| Select minute interval | `Every 15 minutes` |

> **✅** Save 클릭 후 Triggers 목록에 `processMeetingEmails / time-based` 항목이 보이면 완료!

---

## 인식 가능한 이메일 형식

| 인식 키워드 (제목) | 처리 방식 |
|-------------------|-----------|
| 회의, 회의소집, 미팅, meeting, Meeting | 캘린더 일정 **등록** |
| 회의취소, canceled, cancelled, cancel | 캘린더 일정 **삭제** |

### 본문 형식 예시

```
[회의소집] Sea Japan 내부 리뷰 / 2026.03.24 15:00 ~ 16:00 / 발렌시아

* 회의제목 : Sea Japan 내부 리뷰
* 회의일시 : 2026.03.24 15:00 ~ 16:00
* 회의장소 : 상암 12F 발렌시아
```

### 시간 인식 패턴

| 패턴 | 예시 |
|------|------|
| `HH:MM ~ HH:MM` (1순위) | `15:00 ~ 16:00` |
| 오전/오후 N시 ~ 오전/오후 N시 | `오후 3시~오후 4시` |
| 오전/오후 N시 (개별) | `오후 3시`, `오후 4시` |
| 날짜 YYYY.MM.DD | `2026.03.24` |
| 날짜 N월 N일 | `3월 24일` |

---

## 버전 관리

### Apps Script 코드

각 파일 상단 주석으로 버전을 관리합니다.

```javascript
// ================================================
// v4 - YYYY.MM.DD
// 변경 내용을 여기에 기록
// ================================================
```

### 가이드 문서 (Google Drive)

- 파일 우클릭 → 버전 관리 → **Upload new version**
- 업로드 후 이전 버전 옆 ⋮ → **Keep forever** 클릭 (30일 자동 삭제 방지)

---

## 자주 묻는 질문

**Q. 캘린더에 등록이 안 돼요.**

1. 이메일 제목에 `회의` / `미팅` / `meeting` 키워드가 있는지 확인
2. 이메일이 읽음 처리 되어 있지 않은지 확인 (`is:unread` 조건)
3. 날짜 형식이 `YYYY.MM.DD` 또는 `YYYY-MM-DD` 형식인지 확인
4. Execution log에서 오류 메시지 확인

**Q. 회의 취소 메일인데 일정이 삭제 안 돼요.**

1. 제목에 `취소`, `canceled`, `cancelled`, `cancel` 키워드가 있는지 확인
2. 취소 메일의 회의 제목이 등록 시 제목과 정확히 일치하는지 확인
3. 캘린더에 해당 일정이 실제로 존재하는지 확인

**Q. 같은 메일이 중복 등록되나요?**

처리된 메일에는 `캘린더등록완료` 라벨이 붙어 중복 처리를 방지합니다.

**Q. 메일 삭제해도 되나요?**

네, 캘린더 이벤트는 독립적으로 저장되므로 원본 메일을 삭제해도 캘린더 일정에는 영향이 없습니다.

**Q. 15분보다 빠르게 감지할 수 있나요?**

Apps Script 무료 계정 기준 최소 단위가 1분이에요. `everyMinutes(15)` → `everyMinutes(1)`로 변경하면 됩니다. 단, 실행 횟수 제한(하루 90분)이 있으니 참고하세요.

**Q. 파싱 정확도를 더 높이고 싶어요.**

Gemini API 키를 발급받아 `GEMINI_API_KEY`에 입력하면 AI가 자연어로 된 이메일도 정확하게 파싱합니다. [Google AI Studio](https://aistudio.google.com)에서 무료로 발급받을 수 있습니다.
