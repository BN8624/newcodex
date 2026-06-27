# BUILD_REPORT.md

## 1. 게임 제목과 콘셉트

달샘 수호자는 540x960 세로형 방치 RPG다. 달샘 폐허의 수호자가 자동 전투로 성장하고, 성장 버튼으로 전투력을 올려 15층 보스 달그늘 거상을 클리어한다. 이 보고서는 스토어 제출 패키지가 아니라 공개 확인 후보 빌드를 설명한다.

## 2. 구현한 시스템

- `scenes/Main.tscn`을 메인 장면으로 쓰는 Godot 4.x 프로젝트.
- 모바일 우선 540x960 UI, 제목/상태, 공개 확인 배지, 전장, 체력바, 진행 경로, 진행도, 골드, 전투력, 성장 조작.
- 엔진 내부에서 그린 수호자, 적, 보스, 클리어 관문 실루엣과 이동, 피격 플래시, 돌진, 흔들림, 피해 숫자.
- 로컬 Web 확인용 `malgun.ttf`가 있으면 UI와 피해 숫자에 적용되는 한글 폰트 경로.
- 15층 첫 지역, 순환 일반 적 네 종류, 15층 보스 하나.
- 골드와 경험치 보상, 레벨 성장, 층 진행, 보스 클리어 배너, 클리어 후 목표.
- 단계, 증가 비용, 구매 가능 상태, 즉시 효과가 있는 성장 버튼 5개.
- 로컬 JSON 저장/불러오기, 자동 저장, 수동 저장, 2단계 초기화, `save_version`, 제한된 오프라인 골드 보상.
- 핵심 상태 검증을 위한 `--verify` 모드.

## 3. 파일과 폴더 구조

- `project.godot`
- `export_presets.cfg`
- `scenes/Main.tscn`
- `scripts/Main.gd`
- `scripts/GameState.gd`
- `data/game_data.gd`에 둔 게임 데이터 소스.
- `scripts/CombatController.gd`
- `scripts/UIController.gd`
- `scripts/SaveManager.gd`
- `scripts/Effects.gd`
- `scripts/Verifier.gd`
- `assets/placeholders/`
- `assets/ui/`
- `PRODUCT_SPEC.md`
- `checklist.md`
- `context-notes.md`

## 4. 현재 3분 플레이 흐름

플레이어는 게임을 열자마자 제목, 자동 전투 상태, 층 목표, 진행 경로, 골드, 전투력, 체력바, 수호자, 적, 성장 버튼 5개를 본다. 전투는 자동으로 시작되고, 적은 눈에 보이는 피해를 받으며, 처치 후 보상이 뜨고, 세 마리 처치 후 층이 오른다. 성장 버튼은 초반에 빠르게 구매 가능해지고, 15층에서 보스가 등장한다.

## 5. 저장과 불러오기 동작

게임은 시작 시 `user://moonwell_vanguard_save.json`을 불러온다. 성장 구매, 적 보상, 보스 클리어, 수동 저장, 주기적 자동 저장, 종료 요청 시 저장한다. 오프라인 보상은 `last_play_time` 기준이며 최대 2시간으로 제한된다. 새 게임 초기화는 3초 안에 두 번 눌러야 실행된다.

## 6. 실행 방법

Godot 4.7에서 `C:\Users\USER\newcodex\project.godot`을 열고 메인 장면을 실행한다.

CLI 실행 명령.

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --path 'C:\Users\USER\newcodex'
```

검증 명령.

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' -- --verify
```

## 7. 웹 빌드 상태

`export_presets.cfg`에는 Web 스레드 지원을 끈 상태로 `build/web/index.html`을 대상으로 하는 Web 프리셋이 들어 있다. 현재 아이폰 확인 서버는 Godot 4.7로 다시 만든 프로젝트 팩을 Tailscale HTTPS 주소 `https://node.tail3e9e21.ts.net:10000`에서 제공한다.

한글 폰트는 `malgun.ttf`를 로컬 프로젝트 루트에 두면 Web 팩에 포함된다. 이 파일은 상용 시스템 폰트라 공개 저장소에는 커밋하지 않도록 `.gitignore`에 제외했다.

정식 `--export-release`는 아직 아래 위치에 Godot 4.7 내보내기 템플릿이 필요하다.

```text
C:/Users/USER/AppData/Roaming/Godot/export_templates/4.7.stable/
```

템플릿을 설치한 뒤에는 아래 명령으로 정식 Web 내보내기를 실행한다.

```powershell
New-Item -ItemType Directory -Force build\web | Out-Null
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' --export-release 'Web' 'C:\Users\USER\newcodex\build\web\index.html'
```

## 8. 수행한 검증

- 프로젝트 로드 확인 통과.

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' --quit-after 1 --verbose
```

- 핵심 검증기 통과.

```text
PASS: initial state valid
PASS: upgrade purchase changes stat
PASS: enemy defeat gives gold
PASS: stage progression works
PASS: boss clear sets clear state
PASS: save data roundtrip works
VERIFY_RESULT: passed
```

- Tailscale Serve의 HTTPS 주소 `https://node.tail3e9e21.ts.net:10000`에서 모바일 웹 확인을 수행했다.
- 모바일 브라우저 390x844 뷰포트 확인에서 제목 `달샘 수호자`, Godot 캔버스 1개, 캔버스 전체 표시, Secure Context 오류 없음 상태를 확인했다.
- 한국어 표시 수정 뒤 `--verify`를 다시 통과했고, `build/web/index.pck`를 다시 만든 뒤 HTTPS에서 `index.html`과 `index.pck` 응답을 확인했다.
- UI 로드 확인에서 `res://malgun.ttf`와 가져온 fontdata가 정상 로드되는 로그를 확인했다.
- 앱 내 브라우저 스크린샷 캡처는 시간 초과되어, 시각 확인은 DOM과 캔버스 확인 및 Godot 런타임 로드 확인으로 제한됐다.

## 9. 알려진 미구현 기능

인벤토리, 장비, 뽑기, 스킬 트리, 퀘스트, 수익화, 로그인, 클라우드 저장, 랭킹, 전체 오디오, 앱 스토어 패키징, 최종 외주 아트 에셋은 v0.1에서 의도적으로 제외했다.

## 10. 다음 원클릭 스프린트 추천

Godot 4.7 Web 내보내기 템플릿을 설치하고 정식 Web 내보내기를 실행한 뒤, 저장 형식을 바꾸지 않고 짧은 재사용 대기시간 스킬 버튼과 두 번째 지역 데이터 조각을 추가한다.
