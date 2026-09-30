PRAGMA foreign_keys = ON;

-- Q01: 대체 구입비 25,000원 이상 도서를 금액 순으로 조회합니다.
SELECT id, title, replacement_cost FROM book
WHERE replacement_cost >= 25000 ORDER BY replacement_cost DESC, id;

-- Q02: Python 제목이 포함된 도서를 검색합니다.
SELECT id, title FROM book WHERE title LIKE '%Python%' ORDER BY id;

-- Q03: 최근 가입한 회원 3명을 조회합니다.
SELECT id, name, joined_at FROM member ORDER BY joined_at DESC, id DESC LIMIT 3;

-- Q04: 2026-09-30 기준 미반납 연체 후보를 조회합니다.
SELECT id, member_id, book_id, due_at FROM rental
WHERE returned_at IS NULL AND due_at < '2026-09-30' ORDER BY due_at;

-- Q05: 각 도서의 카테고리를 INNER JOIN으로 조회합니다.
SELECT b.title, c.name AS category FROM book b
INNER JOIN category c ON c.id = b.category_id ORDER BY b.id;

-- Q06: 회원과 도서를 연결해 미반납 대여 내역을 조회합니다.
SELECT m.name, b.title, r.due_at FROM rental r
INNER JOIN member m ON m.id = r.member_id
INNER JOIN book b ON b.id = r.book_id
WHERE r.returned_at IS NULL ORDER BY r.id;

-- Q07: 대여 기록이 없는 회원도 LEFT JOIN에 포함합니다.
SELECT m.name, r.id AS rental_id FROM member m
LEFT JOIN rental r ON r.member_id = m.id ORDER BY m.id, r.id;

-- Q08: 카테고리와 도서, 대여 상태를 함께 조회합니다.
SELECT c.name, b.title, r.status FROM category c
INNER JOIN book b ON b.category_id = c.id
INNER JOIN rental r ON r.book_id = b.id ORDER BY r.id;

-- Q09: 회원별 대여 건수를 집계합니다.
SELECT m.name, COUNT(r.id) AS rentals FROM member m
LEFT JOIN rental r ON r.member_id = m.id
GROUP BY m.id, m.name ORDER BY rentals DESC, m.id;

-- Q10: 카테고리별 도서 대체 구입비를 합산합니다.
SELECT c.name, SUM(b.replacement_cost) AS total_cost FROM category c
INNER JOIN book b ON b.category_id = c.id
GROUP BY c.id, c.name ORDER BY total_cost DESC, c.id;

-- Q11: 회원별 반납 도서의 평균 대여 일수를 계산합니다.
-- SQLite 전용 julianday는 ISO 날짜를 일 단위 숫자로 변환합니다.
SELECT m.name, AVG(julianday(r.returned_at) - julianday(r.borrowed_at)) AS average_days
FROM member m INNER JOIN rental r ON r.member_id = m.id
WHERE r.returned_at IS NOT NULL GROUP BY m.id, m.name ORDER BY m.id;

-- Q12: NOT EXISTS 서브쿼리로 대여 기록이 없는 회원을 찾습니다.
SELECT m.id, m.name FROM member m
WHERE NOT EXISTS (SELECT 1 FROM rental r WHERE r.member_id = m.id) ORDER BY m.id;

-- Q13: 미반납이면서 기한이 지난 대여를 overdue로 변경합니다.
-- SQLite 3.35 이상 RETURNING은 변경한 행을 반환합니다.
UPDATE rental SET status = 'overdue'
WHERE returned_at IS NULL AND due_at < '2026-09-30'
RETURNING id, status;

-- Q14: 보관 기간이 지난 반납 기록을 삭제합니다.
-- SQLite 3.35 이상 RETURNING은 삭제한 행을 반환합니다.
DELETE FROM rental WHERE returned_at < '2026-09-01'
RETURNING id, member_id, returned_at;

-- Q15: 회원과 상태로 자주 조회하므로 해당 컬럼에 복합 인덱스를 만듭니다.
CREATE INDEX idx_rental_member_status ON rental(member_id, status);
-- SQLite 전용 EXPLAIN QUERY PLAN으로 인덱스 적용을 확인합니다.
EXPLAIN QUERY PLAN SELECT id FROM rental WHERE member_id = 2 AND status = 'overdue';
