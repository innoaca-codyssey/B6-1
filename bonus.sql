-- 실행 기준: schema.sql + seed.sql 직후의 변경하지 않은 데이터.
-- 1. 프로그래밍 도서: JOIN으로 카테고리 이름과 연결합니다.
SELECT b.id, b.title FROM book b JOIN category c ON c.id = b.category_id
WHERE c.name = '프로그래밍' ORDER BY b.id;
-- 같은 요구를 IN 서브쿼리로 풉니다.
SELECT id, title FROM book WHERE category_id IN
(SELECT id FROM category WHERE name = '프로그래밍') ORDER BY id;

-- 2. 지표 1: 대여가 발생한 월의 대여 건수. strftime은 SQLite 전용입니다.
SELECT strftime('%Y-%m', borrowed_at) AS month, COUNT(*) AS rentals
FROM rental GROUP BY strftime('%Y-%m', borrowed_at) ORDER BY month;

-- 3. 지표 2: 누적 대여 횟수 상위 10권. 동률이면 book.id 오름차순입니다.
SELECT b.id, b.title, COUNT(r.id) AS rentals
FROM book b LEFT JOIN rental r ON r.book_id = b.id
GROUP BY b.id, b.title ORDER BY rentals DESC, b.id LIMIT 10;

-- 4. 지표 3: 기준일 현재 미반납 대여 중 기한이 지난 비율.
-- 고정 기준일 2026-09-30. 분모는 전체 12건이 아닌 미반납 7건입니다.
-- status 문자열 대신 due_at을 비교합니다. 분모 0이면 비율은 NULL입니다.
SELECT COUNT(*) AS active_rentals,
SUM(CASE WHEN due_at < '2026-09-30' THEN 1 ELSE 0 END) AS overdue_rentals,
ROUND(100.0 * SUM(CASE WHEN due_at < '2026-09-30' THEN 1 ELSE 0 END)
/ NULLIF(COUNT(*), 0), 2) AS overdue_percent
FROM rental WHERE returned_at IS NULL;
