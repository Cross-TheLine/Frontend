## Project Structure

```bash
frontend/
├─ assets/
│  └─ images/
│     ├─ tennis_ball.png
│     ├─ intro1.png
│     ├─ intro2.png
│     └─ intro3.png
│
├─ lib/
│  ├─ main.dart                         # 앱 실행 진입점
│  ├─ app.dart                          # MaterialApp, theme, route 설정
│  ├─ routes.dart                       # 앱 라우트 및 화면 정의
│  │
│  ├─ common/                           
│  │  ├─ app_colors.dart                # 색상
│  │  ├─ app_sizes.dart                 # 반응형 크기/패딩 함수
│  │  ├─ app_text_styles.dart           # 텍스트 스타일
│  │  └─ app_button.dart                # 버튼 위젯
│  │
│  ├─ services/                         # 로컬 저장소 / 카메라 / API 관련 서비스
│  │  ├─ local_storage_service.dart
│  │  ├─ camera_service.dart
│  │  └─ api_service.dart              
│  │  └─ screen_orientation.dart
│  │
│  └─ screens/
│     ├─ mainScreen/                    
│     │  ├─ start_screen.dart           # 시작 화면
│     │  └─ intro_screen.dart           # 사용 방법 안내 화면
│     │
│     ├─ vidScreen/                     # 촬영 및 영상 선택 관련 화면
│     │  ├─ video_guideline_screen.dart # 회전/촬영 가이드 화면
│     │  ├─ video_take_screen.dart      # 영상 촬영 화면
│     │  └─ video_pick_screen.dart      # 판별 영상 선택 화면
│     │
│     └─ resultScreen/                  # 판별 결과 관련 화면
│        ├─ loading_result_screen.dart  # 판별 대기 로딩 화면
│        ├─ result_skip_screen.dart     # 판별 건너뛰기 결과 화면
│        └─ result_screen.dart          # 최종 In / Out 결과 화면
│
└─ README.md
