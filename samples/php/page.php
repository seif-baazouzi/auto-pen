<?php

if(!isset($_GET["id"])) {
  header("Location: /pages.php");
  exit();
}

include "includes/db.inc.php";

$id = $_GET["id"];
$res = mysqli_query($conn, "SELECT body FROM pages WHERE id = '$id'");

$err404 = false;
if(mysqli_num_rows($res) == 0) {
  $err404 = true;
} else {
  $row = mysqli_fetch_assoc($res);
  $body = $row["body"];
  $title = $row["title"];
}

mysqli_close($conn);

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page <?= $id ?></title>
</head>
<body>
  <?php if($err404): ?>
    <h1>404 Error</h1>
    <p>Page not found</p>
  <?php else: ?>
    <h1><?= $title ?></h1>
    <p><?= $body ?></p>

    <br><br>
    <a href="/">home</a>
  <?php endif ?>
</body>
</html>