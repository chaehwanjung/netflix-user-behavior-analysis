# 데이터 안내

발표자료의 출처 표기는 **Kaggle Netflix 2025 User Behavior Dataset**이며, 실제 Netflix 고객 데이터가 아닌 스트리밍 서비스를 모사한 시뮬레이션 데이터입니다. 제공 폴더에는 원본 URL과 배포 라이선스 파일이 없어 원본 CSV, 가공 CSV, Tableau 내장 데이터는 공개 저장소에서 제외했습니다. 노트북에 남아 있는 출력과 그래프는 기존 분석 결과입니다.

원본 출처와 이용 조건을 확인한 뒤 아래 파일을 로컬 `data/raw/`에 배치하세요. 특정 Kaggle URL이나 라이선스는 확인 없이 기재하지 않았습니다.

| 파일 | 제공 원본 행 수 |
| --- | ---: |
| `movies.csv` | 1,040 |
| `recommendation_logs.csv` | 52,000 |
| `reviews.csv` | 15,450 |
| `search_logs.csv` | 26,500 |
| `users.csv` | 10,300 |
| `watch_history.csv` | 105,000 |

합계 **210,290행**이며 중복을 포함한 원본 기준입니다. 사용자별 분석 데이터마트는 10,000행, 28열입니다.

## 가공 데이터

SQL의 데이터마트 생성·세그먼트 분석 후 `09_export_datamart.sql`의 최종 SELECT 결과를 MySQL Workbench에서 CSV로 내보내 `data/processed/user_behavior_segment.csv`에 저장하세요. 이 파일에는 사용자당 한 행이 있어야 합니다.

필요 컬럼은 [스키마 파일](processed/schema.json)에 기록했습니다. Git에서 데이터 파일을 추적하지 않도록 설정했습니다.
