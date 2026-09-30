# B6-1: 정보를 깔끔하게 정리하는 디지털 서랍장 만들기

회원, 도서, 카테고리, 대여 기록으로 도서 대여 DB를 구성합니다. SQLite CLI로 스키마와 샘플 데이터를 만들고 조회, 조인, 집계, 서브쿼리, 수정/삭제, 인덱스를 실행합니다.

## 실행 방법

새 데이터베이스 파일에서 실행합니다. SQLite 3.35 이상이 필요합니다.

```bash
sqlite3 library.db < schema.sql
sqlite3 library.db < seed.sql
sqlite3 -header -column -echo library.db < queries.sql
```

SQLite의 FK 검증은 연결마다 활성화합니다. SQL 파일 첫 줄에 PRAGMA foreign_keys=ON을 둡니다. 결과 텍스트는 results에 보관합니다.

## DB 환경

```bash
$ sqlite3 --version
3.43.2 2023-10-10 13:08:14 1b37c146ee9ebb7acd0160c0ab1fd11017a419fa8a3187386ed8cb32b709aapl (64-bit)
```

macOS에 설치된 SQLite CLI를 사용합니다.

## 스키마와 샘플 데이터

```bash
$ sqlite3 -bail ../lab/library.db < schema.sql && sqlite3 -bail ../lab/library.db < seed.sql && sqlite3 -header -column ../lab/library.db "SELECT 'category' AS table_name, COUNT(*) AS rows FROM category UNION ALL SELECT 'member',COUNT(*) FROM member UNION ALL SELECT 'book',COUNT(*) FROM book UNION ALL SELECT 'rental',COUNT(*) FROM rental;"
table_name  rows
----------  ----
category    10  
member      10  
book        12  
rental      12  
```

카테고리와 회원은 각각 10행, 도서와 대여 기록은 각각 12행입니다. 부모 테이블부터 입력하고 FK가 연결되는 순서를 유지했습니다.
