<?php

if(isset($_GET["id"])) {
  include "includes/db.inc.php";

  $id = $_GET["id"];
  $res = mysqli_query($conn, "SELECT title FROM pages WHERE id = '$id'");
  
  $row = mysqli_fetch_assoc($res);
  if($row) $title = $row["title"];

  mysqli_close($conn);
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  <h1>Search by id</h1>
  <form>
    <div>
      <label>ID</label>
      <input type="text" name="id">
    </div>
    <button>Search</button>
  </form>
  <?php
    if(isset($title)) {
      echo "<p>$title</p>";
    } else {
      echo "<p>Page with id $id not found</p>";
    }
  ?>
</body>
</html>