<?php
  if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!isset($_POST['login']) || !isset($_POST['password']) ||
        !$_POST['login'] || !$_POST['password']) {
      $error = 'Login and password are required';
    }
    else {
      $passwd = $_POST['login'] . ':' . crypt($_POST['password']);
      file_put_contents('/var/www/credentials', $passwd);
      header('Location: /');
      die('Reload the page');
    }
  }
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Create your ruTorrent accounts</title>
    <style type="text/css">
      body {
        background-color: #ddd;
        width: 800px;
        margin: 0 auto;
        color: black;
      }

      h1 {
        border-bottom: 3px solid black;
      }

      .beware {
        color: #a00;
        font-weight: bold;
        font-size: 1.4em;
      }

      .error {
        background-color: rgba(255, 0, 0, 0.2);
        padding: 10px;
        font-weight: bold;
        font-size: 1.4em;
      }

      form label {
        display: block;
        margin: 25px;
      }

      form input {
        width: 100%;
      }
    </style>
  </head>
  <body>
    <h1>Create an account</h1>
    <p>
      Create an account to access to your torrents.
      <span class="beware">Beware: your account can't be easily updated later.
      You need to remember your login and password.</span>
    </p>

    <?php
      if (isset($error))
        echo '<div class="error">' . $error . '</div>';
    ?>

    <form method="POST" action=".">
      <label for="login">Login: <input id="login" name="login" type="text"></label>
      <label for="password">Password: <input id="password" name="password" type="password"></label>
      <input type="submit" value="Create account">
    </form>
  </body>
</html>
