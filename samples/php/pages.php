<?php

include "includes/db.inc.php";
$res = mysqli_query($conn, "SELECT id, title FROM pages");

mysqli_close($conn);

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pages</title>
</head>
<body>
  <h1>Pages</h1>
  <ul>
    <?php
      while($row = mysqli_fetch_assoc($res)) {
        $id = $row["id"];
        $title = $row["title"];
        echo "<li><a href='/page.php?id=$id'>$title</a></li>";
      }
    ?>
  </ul>
  <br><br>
  <a href="/">home</a>
</body>
</html>