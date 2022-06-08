CREATE DATABASE sample;
USE sample;

CREATE TABLE pages (
  id int PRIMARY KEY AUTO_INCREMENT,
  title varchar(50) NOT NULL,
  body text NOT NULL
);

INSERT INTO pages VALUES (null, 'Page 1', 'Lorem ipsum dolor sit amet consectetur, adipisicing elit. Soluta fugit labore dolore quisquam, nemo enim cumque harum deleniti ex dicta laborum itaque consequuntur iusto? Corporis quae porro repudiandae eos ex.');
INSERT INTO pages VALUES (null, 'Page 2', 'Lorem ipsum dolor sit amet consectetur, adipisicing elit. Soluta fugit labore dolore quisquam, nemo enim cumque harum deleniti ex dicta laborum itaque consequuntur iusto? Corporis quae porro repudiandae eos ex.');
