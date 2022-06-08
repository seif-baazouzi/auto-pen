<?php

$uri = $_SERVER['REQUEST_URI'];
if($uri != "/" && $uri != "/index.php") {
    http_response_code(404);
    require "404.php";
    exit();
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Home</title>
</head>
<body>
  <h1>Home page</h1>
  <p>Lorem ipsum dolor sit amet consectetur, adipisicing elit. Soluta fugit labore dolore quisquam, nemo enim cumque harum deleniti ex dicta laborum itaque consequuntur iusto? Corporis quae porro repudiandae eos ex.</p>
  <a href="/about.php">About</a>
  <a href="/pages.php">Pages</a>
  <a href="/files.php">Files</a>
  <a href="/search.php">Search</a>
</body>
</html>
