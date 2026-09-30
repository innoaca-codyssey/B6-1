-- SQLite: 연결마다 FK 검증을 활성화합니다.
PRAGMA foreign_keys = ON;
CREATE TABLE category (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
CREATE TABLE member (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    joined_at TEXT NOT NULL
);
CREATE TABLE book (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    category_id INTEGER NOT NULL REFERENCES category(id) ON DELETE RESTRICT,
    replacement_cost INTEGER NOT NULL CHECK (replacement_cost > 0)
);
CREATE TABLE rental (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES member(id) ON DELETE RESTRICT,
    book_id INTEGER NOT NULL REFERENCES book(id) ON DELETE RESTRICT,
    borrowed_at TEXT NOT NULL,
    due_at TEXT NOT NULL,
    returned_at TEXT,
    status TEXT NOT NULL CHECK (status IN ('borrowed', 'returned', 'overdue')),
    CHECK (due_at >= borrowed_at),
    CHECK (returned_at IS NULL OR returned_at >= borrowed_at),
    CHECK ((status = 'returned' AND returned_at IS NOT NULL) OR (status <> 'returned' AND returned_at IS NULL))
);
