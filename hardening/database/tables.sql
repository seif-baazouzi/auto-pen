CREATE DATABASE hardening;

\c hardening;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE admins (
  username VARCHAR PRIMARY KEY,
  password VARCHAR NOT NULL
);

INSERT INTO admins VALUES ('admin', '$2b$10$GaEOe/Gz4pTz2ZtThpxIN.M4bXmKgLcW/OW6jbkwwyiSJQdzzN632');

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE technologies (
  name VARCHAR PRIMARY KEY,
  hardening text NOT NULL
);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE users (
  email VARCHAR PRIMARY KEY,
  password VARCHAR NOT NULL,
  apikey VARCHAR NOT NULL
);

INSERT INTO users VALUES (
  'exploit@exploit.com',
  '$2a$10$LH35Aicgr8kYX.e8ucKcd.5M71KrjuQ71qE5DLLcpP9xs4zRGjNX.',
  '439b3f3b-860c-4048-b9b2-5965eed80bb3'
);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE logs (
  logID SERIAL PRIMARY KEY,
  email VARCHAR NOT NULL,
  query VARCHAR NOT NULL,
  logDate timestamp not null default CURRENT_TIMESTAMP,
  CONSTRAINT user_log FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE technologies_log (
  technologiesLogID SERIAL PRIMARY KEY,
  logID INT NOT NULL,
  technologie VARCHAR NOT NULL,
  CONSTRAINT querylogs FOREIGN KEY (logID) REFERENCES logs(logID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT technologielogs FOREIGN KEY (technologie) REFERENCES technologies(name) ON DELETE CASCADE ON UPDATE CASCADE
);
